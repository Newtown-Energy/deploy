# MSMTP

This is a bit different than some other services in `../deploy`.  It's
not a web service, for example.

At some point or another, every box tends to want some way to send
emails.  Whether it's cron jobs, password resets, or OTP tokens, we
often come to want SMTP. I don't tend to need a full on email system,
though.  Local mail isn't very useful or necessary.

MSMTP fills that gap between none and all.  It's just enough
`sendmail`.

## Install

These deploy scripts typically favor docker, but here we're going to
put this at the system level.

```
./dosh push TARGET-SERVER-FQDN
ssh TARGET-SERVER-FQDN
cd /opt/msmtp
[Edit .env]
./dosh install
```

You might want to run `test.py` and see if it works.  The different
tests exercise different ways of connection.  Via msmtp, via sendmail,
via direct SMTP to upstream SMTP, via SMTP to the msmtpd listener.  If
any of these fails, something went wrong.

## From Emails

We can register valid from emails with zoho.  Right now, we have the
generic "bot@newtown.energy", but for some services it might be useful
to have servicename@newtown.energy.

Somewhere in https://zeptomail.zoho.com/ you can add/remove addresses.
I forget where.

## IP Restrictions

Under `Settings` in https://zeptomail.zoho.com/ you can add/remove IP
addresses.  We are currently rolling with no restrictions because some
of our services are behind dynamic IPs.  We could do some kind of
VPN-based smart-host thing, but so far I haven't though it necessary.
Outgoing email isn't where our risk is.
