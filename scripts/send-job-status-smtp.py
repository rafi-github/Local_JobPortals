#!/usr/bin/env python3
"""Send a job status report over authenticated STARTTLS SMTP."""
import argparse
import os
import smtplib
import ssl
from email.message import EmailMessage
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--to", required=True)
    parser.add_argument("--subject", required=True)
    parser.add_argument("--body-file", required=True)
    args = parser.parse_args()

    host = os.environ["SMTP_HOST"]
    port = int(os.environ.get("SMTP_PORT", "587"))
    user = os.environ["SMTP_USER"]
    password = os.environ["SMTP_PASSWORD"]
    sender = os.environ.get("SMTP_FROM", user)

    msg = EmailMessage()
    msg["From"] = sender
    msg["To"] = args.to
    msg["Subject"] = args.subject
    msg.set_content(Path(args.body_file).read_text(encoding="utf-8"))

    context = ssl.create_default_context()
    with smtplib.SMTP(host, port, timeout=30) as smtp:
        smtp.ehlo()
        smtp.starttls(context=context)
        smtp.ehlo()
        smtp.login(user, password)
        smtp.send_message(msg)
    print("Email sent via SMTP")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        # Avoid serializing settings, credentials, message body, or server replies.
        print(f"SMTP delivery failed ({type(exc).__name__})", file=__import__("sys").stderr)
        raise SystemExit(1)
