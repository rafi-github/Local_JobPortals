#!/usr/bin/env node
/**
 * Detect Indeed Cloudflare / Akamai blocks and stop without bypass attempts.
 *
 * Exit codes:
 *   0 — reachable through the normal connection
 *   5 — portal access blocked; skipped without bypass attempts
 *   1 — unexpected network/runtime error
 *   2 — configured network error
 *
 * Uses the normal configured connection. It never rotates proxies or solves
 * security challenges.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const os = require("os");
const { spawnSync } = require("child_process");

const ROOT = path.resolve(__dirname, "../..");
const OUT =
  process.env.INDEED_PREFLIGHT_REPORT ||
  path.join(ROOT, "artifacts", "indeed-preflight.json");
const URL = process.env.INDEED_PREFLIGHT_URL || "https://in.indeed.com/";

function writeReport(report) {
  fs.mkdirSync(path.dirname(OUT), { recursive: true });
  fs.writeFileSync(OUT, JSON.stringify(report, null, 2));
}

function isCloudflareBlocked(status, text, title) {
  const blob = `${status || ""} ${title || ""} ${text || ""}`;
  return (
    status === 403 ||
    /additional verification required|security check|request blocked|you have been blocked|just a moment|cloudflare|cf-ray|ray id|blocked - indeed/i.test(
      blob,
    )
  );
}

/** curl prefers socks5h:// so DNS goes through the proxy. */
function curlProxy(proxy) {
  if (!proxy) return "";
  if (proxy.startsWith("socks5://")) {
    return "socks5h://" + proxy.slice("socks5://".length);
  }
  return proxy;
}

function curlFetch(url, proxy) {
  const bodyPath = path.join(os.tmpdir(), `indeed-preflight-${process.pid}.html`);
  const args = [
    "-sS",
    "-L",
    "--max-redirs",
    "3",
    "-o",
    bodyPath,
    "-w",
    "%{http_code}",
    "--max-time",
    "45",
  ];
  const px = curlProxy(proxy);
  if (px) args.push("-x", px);
  args.push(url);
  const res = spawnSync("curl", args, { encoding: "utf8" });
  if (res.error) throw res.error;
  const status = Number(String(res.stdout || "").trim()) || 0;
  const text = fs.existsSync(bodyPath)
    ? fs.readFileSync(bodyPath, "utf8")
    : "";
  fs.rmSync(bodyPath, { force: true });
  return { status, text, curlExit: res.status };
}

/** Extract a JSON object from mixed stdout (SeleniumBase may prepend driver noise). */
function parseJsonBlob(text, fallbackPaths = []) {
  const raw = String(text || "").trim();
  if (raw) {
    try {
      return JSON.parse(raw);
    } catch {
      /* try braced slice below */
    }
    const start = raw.indexOf("{");
    const end = raw.lastIndexOf("}");
    if (start >= 0 && end > start) {
      try {
        return JSON.parse(raw.slice(start, end + 1));
      } catch {
        /* fall through to report files */
      }
    }
  }
  for (const p of fallbackPaths) {
    if (p && fs.existsSync(p)) {
      try {
        return JSON.parse(fs.readFileSync(p, "utf8"));
      } catch {
        /* try next */
      }
    }
  }
  return null;
}

function chromeProbe(url, proxy) {
  const probe = path.join(__dirname, "chrome_probe.js");
  if (!fs.existsSync(probe)) return null;
  const env = { ...process.env };
  env.INDEED_HTTP_PROXY = proxy || "";
  for (const key of ["HTTPS_PROXY", "HTTP_PROXY", "https_proxy", "http_proxy"]) {
    if (/(?:127\.0\.0\.1|localhost):40000/.test(env[key] || "")) env[key] = "";
  }
  const res = spawnSync(process.execPath, [probe, url], {
    encoding: "utf8",
    env,
    timeout: 120000,
  });
  const parsed = parseJsonBlob(res.stdout || "");
  if (parsed) return parsed;
  return {
    ok: false,
    error: (res.stderr || res.stdout || "chrome_probe failed").slice(0, 500),
    exitCode: res.status,
  };
}

function probeOnce(proxy) {
  const { status, text } = curlFetch(URL, proxy || undefined);
  const title = (text.match(/<title[^>]*>([^<]+)/i) || [])[1] || "";
  const httpBlocked = isCloudflareBlocked(status, text, title);
  let chrome = null;
  if (process.env.INDEED_CHROME_PROBE === "1") {
    chrome = chromeProbe(URL, proxy || undefined);
  }
  return {
    httpStatus: status,
    title,
    bodySample: text.replace(/\s+/g, " ").slice(0, 500),
    httpBlocked,
    chrome,
    chromeOk: Boolean(chrome && chrome.ok),
    blocked: Boolean(
      httpBlocked || Boolean(chrome && chrome.blocked),
    ),
  };
}

function main() {
  const configuredProxy =
    process.env.INDEED_HTTP_PROXY ||
    process.env.HTTPS_PROXY ||
    process.env.HTTP_PROXY ||
    process.env.https_proxy ||
    process.env.http_proxy ||
    "";
  const initialProxy = /(?:127\.0\.0\.1|localhost):40000/.test(configuredProxy)
    ? ""
    : configuredProxy;

  const report = {
    startedAt: new Date().toISOString(),
    url: URL,
    ok: false,
  };

  try {
    // Do not route around an Indeed security block with proxy rotation or
    // challenge automation. Probe through the configured normal connection.
    const proxy = initialProxy;
    report.proxySkipped = Boolean(configuredProxy && !proxy);
    report.warp = { started: false, skipped: true, reason: "disabled_compliant_access" };
    report.proxyConfigured = Boolean(proxy);
    report.proxyHost = proxy ? proxy.replace(/\/\/.*@/, "//***@") : null;

    let probe = probeOnce(proxy);
    Object.assign(report, {
      httpStatus: probe.httpStatus,
      title: probe.title,
      bodySample: probe.bodySample,
      httpBlocked: probe.httpBlocked,
      chrome: probe.chrome,
    });

    if (probe.chromeOk) {
      report.ok = true;
      report.reason = "chrome_reachable";
      writeReport(report);
      console.log(JSON.stringify(report, null, 2));
      process.exit(0);
    }

    if (probe.httpBlocked || (probe.chrome && probe.chrome.blocked)) {
      report.reason = "indeed_access_denied_or_security_challenge";
      report.hint =
        "Indeed denied access (HTTP 403/security challenge). The portal was skipped; sign in or retry manually later through the official site.";
      writeReport(report);
      console.error(JSON.stringify(report, null, 2));
      process.exit(5);
    }

    if (!probe.httpStatus || probe.httpStatus >= 400) {
      report.reason = probe.httpStatus
        ? `indeed_http_${probe.httpStatus}_skipped`
        : "network_probe_failed";
      report.hint = probe.httpStatus
        ? "Indeed returned an error status; skip automation and retry manually through the official site."
        : "Could not reach Indeed through the normal configured connection.";
      writeReport(report);
      console.error(JSON.stringify(report, null, 2));
      process.exit(1);
    }

    report.ok = true;
    report.reason = "reachable";
    writeReport(report);
    console.log(JSON.stringify(report, null, 2));
  } catch (error) {
    report.reason = "network_error";
    report.error = String(error).slice(0, 500);
    writeReport(report);
    console.error(JSON.stringify(report, null, 2));
    process.exit(1);
  }
}

main();
