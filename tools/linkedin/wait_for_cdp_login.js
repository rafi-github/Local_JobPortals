#!/usr/bin/env node
/**
 * Live CDP check / wait for a signed-in LinkedIn page at :9222.
 *  * Authentication is checked only from the visible page.
 *
 * Usage:
 *   node tools/linkedin/wait_for_cdp_login.js            # one-shot probe
 *   node tools/linkedin/wait_for_cdp_login.js --wait 120 # poll seconds
 *   node tools/linkedin/wait_for_cdp_login.js --open-login
 */
"use strict";

const path = require("path");

const CDP = process.env.LINKEDIN_CDP || "http://127.0.0.1:9222";
const ROOT = path.resolve(__dirname, "../..");

function argValue(flag) {
  const i = process.argv.indexOf(flag);
  if (i === -1 || i + 1 >= process.argv.length) return null;
  return process.argv[i + 1];
}

function safeUrl(value) { try { const u = new URL(value); return u.origin + u.pathname; } catch { return ""; } }

/**
 * Logged-in feed copy often contains the word "challenge". A security
 * checkpoint is a /checkpoint or /challenge URL, or an interstitial when the
 * page is not an authenticated feed/profile.
 */
function classifyLinkedInSession(url, body) {
  const pathUrl = safeUrl(url) || String(url || "");
  const text = String(body || "");
  const top = text.slice(0, 1800);
  const authenticatedView =
    /\/feed|\/in\/|\/jobs/i.test(pathUrl) &&
    /Home|My Network|Jobs|Messaging/i.test(text);
  const urlChallenge = /\/checkpoint(?:\/|$)|\/challenge(?:\/|$)|security-verification/i.test(
    pathUrl
  );
  const interstitial =
    /let'?s do a quick security check|security verification|verify it'?s you|unusual activity from your|confirm your identity/i.test(
      top
    );
  const onChallenge = urlChallenge || (interstitial && !authenticatedView);
  const urlLogin = /\/login|authwall|\/uas\/login|\/checkpoint(?:\/|$)/i.test(pathUrl);
  const loginWallCopy =
    !authenticatedView &&
    /sign in to linkedin|join now|new to linkedin|sign in to continue/i.test(top);
  const loginish = urlLogin || loginWallCopy;
  const ok = !loginish && !onChallenge && authenticatedView;
  let reason = "linkedin_login_required";
  if (ok) reason = "live_cdp_linkedin_ok";
  else if (onChallenge) reason = "linkedin_security_challenge";
  return { ok, url: pathUrl, onChallenge, reason };
}

async function main() {
  const waitSec = Number(argValue("--wait") || process.env.LINKEDIN_LOGIN_WAIT_SEC || "0");
  const openLogin = process.argv.includes("--open-login");

  let chromium;
  try {
    chromium = require("playwright-core").chromium;
  } catch {
    try {
      // eslint-disable-next-line import/no-dynamic-require
      chromium = require(path.join(ROOT, "tools/node_modules/playwright-core")).chromium;
    } catch (err) {
      console.error(
        JSON.stringify({
          ok: false,
          reason: "playwright_core_missing",
          error: String(err && err.message ? err.message : err),
        })
      );
      process.exit(2);
    }
  }

  let browser;
  try {
    browser = await chromium.connectOverCDP(CDP);
  } catch (err) {
    console.error(
      JSON.stringify({
        ok: false,
        reason: "cdp_connect_failed",
        cdp: CDP,
        error: String(err && err.message ? err.message : err),
        hint: "bash scripts/launch-chrome-cdp.sh linkedin",
      })
    );
    process.exit(4);
  }

  const ctx = browser.contexts()[0] || (await browser.newContext());

  function pickLinkedInPage(preferChallenge = false) {
    const pages = ctx.pages() || [];
    const li = pages.filter((p) => /linkedin\.com/i.test(p.url() || ""));
    const feedish = li.find((p) =>
      /\/feed|\/jobs|\/in\//i.test(p.url() || "")
    );
    const challenge = li.find((p) =>
      /\/checkpoint|\/challenge|security-verification/i.test(p.url() || "")
    );
    // Prefer feed/jobs when a session exists; only stick to challenge when
    // there is no li_at yet (owner must finish CAPTCHA). Leftover challenge
    // tabs after Google SSO must not false-fail a good session.
    if (preferChallenge && challenge) return challenge;
    if (feedish) return feedish;
    if (challenge) return challenge;
    if (li[0]) return li[0];
    return pages[0] || null;
  }

  let page = pickLinkedInPage() || (await ctx.newPage());

  async function probe() {
    let url = page.url() || "";
    if (openLogin || !/linkedin\.com/i.test(url)) {
      await page.goto("https://www.linkedin.com/login", { waitUntil: "domcontentloaded", timeout: 60000 }).catch(() => {});
    } else {
      await page.goto("https://www.linkedin.com/feed/", { waitUntil: "domcontentloaded", timeout: 60000 }).catch(() => {});
    }
    url = page.url() || "";
    const body = await page.evaluate(() => (document.body && document.body.innerText) || "").catch(() => "");
    return classifyLinkedInSession(url, body);
  }

  const deadline = Date.now() + Math.max(0, waitSec) * 1000;
  let last = await probe();
  if (last.ok) {
    console.log(JSON.stringify({ ...last, waitedSec: 0 }));
    process.exit(0);
  }

  const systemHint =
    process.env.CHROME_CDP_MODE === "system"
      ? "system Chrome Default (CHROME_CDP_MODE=system)"
      : "profile under ~/.cursor/chrome-cdp-profiles/linkedin";

  if (waitSec > 0) {
    console.error(
      "LinkedIn CDP login required — complete sign-in / Security Verification in the headed Chrome window " +
        `(${systemHint}). ` +
        `Waiting up to ${waitSec}s…`
    );
    console.error("Or: bash scripts/home-headed-login.sh linkedin");
    while (Date.now() < deadline) {
      await new Promise((r) => setTimeout(r, 8000));
      last = await probe();
      console.error(
        JSON.stringify({
          waiting: true,          url: last.url,
          secsLeft: Math.max(0, Math.round((deadline - Date.now()) / 1000)),
        })
      );
      if (last.ok) {
        console.log(
          JSON.stringify({
            ...last,
            waitedSec: Math.round(waitSec - (deadline - Date.now()) / 1000),
          })
        );
        process.exit(0);
      }
    }
  }

  const challenge =
    last.onChallenge || /\/checkpoint(?:\/|$)|\/challenge(?:\/|$)|security-verification/i.test(last.url || "");
  console.log(
    JSON.stringify({
      ok: false,
      reason: challenge ? "linkedin_security_challenge" : "linkedin_login_required",      onChallenge: !!challenge,
      url: last.url,
      hint: "bash scripts/home-headed-login.sh linkedin",    })
  );
  process.exit(5);
}

if (require.main === module) {
  main().catch((err) => {
    console.error(JSON.stringify({ ok: false, reason: "unexpected", error: String(err) }));
    process.exit(1);
  });
}

module.exports = { classifyLinkedInSession, safeUrl };
