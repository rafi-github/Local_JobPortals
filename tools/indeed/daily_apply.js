#!/usr/bin/env node
/** Indeed preflight only: never bypass access controls or submit applications. */
"use strict";

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const OUT =
  process.env.INDEED_DAILY_REPORT ||
  path.join(process.cwd(), "artifacts", "indeed-daily-run.json");
const PREFLIGHT = path.join(__dirname, "preflight.js");

function parseJson(text) {
  const raw = String(text || "").trim();
  try {
    return JSON.parse(raw);
  } catch {
    const start = raw.indexOf("{");
    const end = raw.lastIndexOf("}");
    if (start >= 0 && end > start) {
      try {
        return JSON.parse(raw.slice(start, end + 1));
      } catch {
        return null;
      }
    }
    return null;
  }
}

function main() {
  const startedAt = new Date().toISOString();
  const result = spawnSync(process.execPath, [PREFLIGHT], {
    encoding: "utf8",
    env: {
      ...process.env,
      INDEED_HTTP_PROXY: "",
      INDEED_SKIP_WARP: "1",
      INDEED_SKIP_UC_BYPASS: "1",
    },
    timeout: 180000,
  });
  const preflight = parseJson(`${result.stdout || ""}\n${result.stderr || ""}`);
  const blockedByPortal = result.status === 5;
  const reason = blockedByPortal
    ? "indeed_cloudflare_or_security_challenge_skipped"
    : result.status === 0
      ? "indeed_automation_disabled_compliant_access_only"
      : "indeed_preflight_failed";
  const report = {
    portal: "indeed",
    source: "home-local",
    date: new Intl.DateTimeFormat("en-CA", {
      timeZone: "Asia/Kolkata",
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).format(new Date()),
    startedAt,
    finishedAt: new Date().toISOString(),
    host: require("os").hostname(),
    ok: false,
    counts: { applied: 0, external: 0, rejected: 0, blocked: 1, skipped: 0, seen: 0 },
    applied: [],
    external: [],
    rejected: [],
    blocked: [{ reason }],
    skipped: [],
    seen: [],
    blockerSummary: reason,
    preflight,
  };
  fs.mkdirSync(path.dirname(OUT), { recursive: true });
  fs.writeFileSync(OUT, JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify(report, null, 2));
  return result.status === 0 ? 5 : result.status || 1;
}

process.exit(main());
