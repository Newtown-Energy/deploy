#!/usr/bin/env python3

"""

This script connects to an SMTP server and sends a test email.  It
doesn't use sendmail or msmtp, but uses the Python standard library's
smtplib and ssl modules.

If this script works but your msmtp doesn't, then you know that your
credentials work and your SMTP transactional email service provider is
functioning correctly.
"""

from email.message import EmailMessage
import os
import smtplib
import subprocess
import ssl
import sys

def get_env_value(key, env_file='.env'):
    """
    Get the value for `key` from the environment.
    If not found, try loading from .env file and return.
    Only uses the Python standard library.
    """
    # First, try to get from environment
    value = os.environ.get(key)
    if value is not None:
        return value

    # If not found, try to read from .env file
    try:
        with open(env_file, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if '=' not in line:
                    continue
                k, v = line.split('=', 1)
                k = k.strip()
                v = v.strip().strip('"').strip("'")
                if k == key:
                    return v
    except FileNotFoundError:
        pass

    return None

def smtp():
    print("Testing SMTP...")
    # Get account details from environment or .env file
    port = int(get_env_value("PORT"))
    smtp_server = get_env_value("SMTP_SERVER")
    username=get_env_value("USERNAME")
    password = get_env_value("PASSWORD")
    to_email = get_env_value("TEST_RECIPIENT")

    # Build message
    message = "Test message sent from python script verifies that zoho credentials work to send transactional email. This doesn't test msmtp or sendmail."
    msg = EmailMessage()
    msg['Subject'] = "Test Email"
    msg['From'] = "bot@newtown.energy"
    msg['To'] = "james@newtown.energy"
    msg.set_content(message)

    # Send message
    try:
        if port == 465:
            context = ssl.create_default_context()
            with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
                server.login(username, password)
                server.send_message(msg)
        elif port == 587:
            with smtplib.SMTP(smtp_server, port) as server:
                server.starttls()
                server.login(username, password)
                server.send_message(msg)
        else:
            print ("use 465 / 587 as port value")
            exit()
        print ("successfully sent via SMTP")
    except Exception as e:
        print (e)

def msmtp():
    print("Testing msmtp...")
    to_email = get_env_value("TEST_RECIPIENT")

    subject = "Test MSMTP via Python"
    body = "This is a test email sent using msmtp via Python."

    # Construct the email in a format msmtp can read
    email_content = f"Subject: {subject}\n\n{body}"

    try:
        # Use subprocess to call msmtp
        result = subprocess.run(
            ["msmtp", to_email],
            input=email_content.encode(),
            check=True,
            capture_output=True
        )
        print(f"Test email sent successfully to {to_email} via msmtp")
    except subprocess.CalledProcessError as e:
        print(f"Failed to send email: {e.stderr.decode()} via msmtp")
        exit(1)

def sendmail():
    print("Testing sendmail...")
    to_email = get_env_value("TEST_RECIPIENT")
    mail_from = get_env_value("MAIL_FROM")
    subject = "Test email via Sendmail"
    body = "This is a test email sent using the sendmail command."

    # Construct the email in RFC5322 format
    email_content = f"""From: {mail_from}
To: {to_email}
Subject: {subject}

{body}
"""

    try:
        # Call the sendmail command
        result = subprocess.run(
            ["sendmail", "-t"],  # -t = read recipients from "To:" header
            input=email_content.encode(),
            check=True,
            capture_output=True
        )
        print(f"Test email sent successfully to {to_email} via sendmail")
    except subprocess.CalledProcessError as e:
        print(f"Failed to send email via sendmail: {e.stderr.decode()}")
        exit(1)


def msmtpd():
    print("Testing msmtpd...")
    # Use environment variables if possible, otherwise use sensible defaults
    to_email = get_env_value("TEST_RECIPIENT")
    mail_from = get_env_value("MAIL_FROM")
    smtp_server = get_env_value("LISTEN_INTERFACE")
    port = 25

    subject = "Test Email via msmtpd SMTP"
    body = f"This is a test email sent using direct SMTP to an msmtpd daemon at {smtp_server}"

    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = mail_from
    msg['To'] = to_email
    msg.set_content(body)

    try:
        with smtplib.SMTP(smtp_server, port, timeout=10) as server:
            server.send_message(msg)
        print(f"Test email sent successfully to {to_email} via direct SMTP connection to {smtp_server}:25")
    except Exception as e:
        print(f"Failed to send email via local SMTP: {e}")
if __name__ == "__main__":
    if len(sys.argv) < 2:
        smtp()
        msmtp()
        sendmail()
        msmtpd()
    else:
        if sys.argv[1] == "smtp":
            smtp()
        elif sys.argv[1] == "msmtp":
            msmtp()
        elif sys.argv[1] == "sendmail":
            sendmail()
        elif sys.argv[1] == "msmtpd":
            msmtpd()
        else:
            sys.stderr.write("Unknown command: " + sys.argv[1]+"\n")
            sys.exit(1)
