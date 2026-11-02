#!/usr/bin/env python3
"""Send the job-status report via Gmail compose in the open Chrome (CDP :9222).

Same delivery as Local_JobsHyderabad/notify_daily_email.py when Resend is unset.
Requires Playwright (the Hyderabad .venv works with current Chrome).
"""
from __future__ import annotations

import argparse
import sys
import urllib.parse

CDP = "http://127.0.0.1:9222"


def _signed_in(page) -> bool:
    try:
        url = (page.url or "").lower()
    except Exception:
        return False
    if "accounts.google.com" in url:
        return False
    return "mail.google.com/mail" in url


def _click_send(page) -> bool:
    for sel in (
        'div[role="button"][aria-label^="Send"]',
        'div[role="button"][data-tooltip^="Send"]',
        'div[aria-label="Send ‪(Ctrl-Enter)‬"]',
    ):
        loc = page.locator(sel).first
        try:
            if loc.count() and loc.is_visible():
                loc.click(timeout=5000)
                return True
        except Exception:
            continue
    try:
        page.keyboard.press("Control+Enter")
        return True
    except Exception:
        return False


def send(to: str, subject: str, body: str) -> None:
    from playwright.sync_api import sync_playwright

    params = urllib.parse.urlencode(
        {"view": "cm", "fs": "1", "tf": "1", "to": to, "su": subject[:200]},
        quote_via=urllib.parse.quote,
    )
    with sync_playwright() as pw:
        browser = pw.chromium.connect_over_cdp(CDP, timeout=60000)
        if not browser.contexts:
            raise SystemExit("Gmail compose: Chrome CDP has no browser context.")
        context = browser.contexts[0]
        page = context.new_page()
        try:
            page.goto(
                f"https://mail.google.com/mail/u/0/?{params}",
                wait_until="domcontentloaded",
                timeout=45000,
            )
            page.wait_for_timeout(2500)
            if not _signed_in(page):
                raise SystemExit(
                    "Gmail compose: Chrome is not signed in to Gmail. "
                    "Open mail.google.com in the CDP Chrome and retry."
                )
            body_el = page.locator(
                'div[aria-label="Message Body"], div[role="textbox"]'
            ).first
            try:
                if body_el.count():
                    body_el.click(timeout=5000)
                    body_el.fill(body[:15000], timeout=8000)
            except Exception:
                page.keyboard.type(body[:4000], delay=0)
            if not _click_send(page):
                raise SystemExit("Gmail compose: Send button not found.")
            page.wait_for_timeout(2500)
            blob = ""
            try:
                blob = (page.inner_text("body") or "").lower()
            except Exception:
                blob = ""
            if "couldn't send" in blob or "couldn’t send" in blob:
                raise SystemExit("Gmail compose: send failed on page.")
            print("Email sent: gmail-compose", flush=True)
        finally:
            try:
                page.close()
            except Exception:
                pass


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--to", required=True)
    parser.add_argument("--subject", required=True)
    parser.add_argument("--body-file", required=True)
    args = parser.parse_args()
    body = open(args.body_file, encoding="utf-8").read()
    try:
        send(args.to, args.subject, body)
    except SystemExit:
        raise
    except Exception as exc:
        print(f"Gmail compose failed ({type(exc).__name__}): {exc}", file=sys.stderr)
        raise SystemExit(1) from exc


if __name__ == "__main__":
    main()
