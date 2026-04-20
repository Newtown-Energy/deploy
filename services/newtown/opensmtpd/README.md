# newtown-opensmtpd

OpenSMTPD relay for newtown. Listens on loopback and VPN interface, routes
outbound mail through upstream SMTP providers based on sender domain.
Replaces `newtown-msmtp`.

## Upstreams

| Domain | Provider | Port |
|--------|----------|------|
| `@newtownenergy.com` | MXroute (witcher.mxrouting.net) | 2525 |
| `@newtown.energy` | ZeptoMail (smtp.zeptomail.com) | 587 — **currently broken** (outbound 587 blocked on DO; pending migration to MXroute) |

## Listeners

- `127.0.0.1:587`, `127.0.0.1:2525` — loopback
- `10.1.0.1:587`, `10.1.0.1:2525` — VPN interface

Accepts connections from local processes (`from local`), loopback TCP, and
the VPN subnet (`10.1.0.0/24`). All other sources are rejected.

## From validation

Senders are validated against per-domain tables. Mail from an address not in
the allowed list is rejected at the SMTP layer.

Allowed senders are configured in inventory via `opensmtpd_newtownenergy_from`
and `opensmtpd_newtown_energy_from`.

## Deploy

```
runcible newtown-opensmtpd services/newtown/opensmtpd/manage install
```

Requires `newtown-msmtp` to be removed first — both provide `mail-transport-agent`.

## Manage commands

- `install` — install opensmtpd, write config and credentials, start service
- `uninstall` — stop service, remove config files
- `status` — show systemd status; dump recent logs if not running
- `test` — send test emails from each allowed sender to a mailsac.com inbox

## Useful smtpctl commands

`smtpctl` runs on the remote. Either SSH in, or use runcible with `--`:

```bash
# Via runcible
runcible newtown-opensmtpd -- smtpctl show queue
runcible newtown-opensmtpd -- smtpctl remove <evpid>

# Or via SSH
ssh root@newtownenergy.com smtpctl show queue
```

Common operations:

```bash
# Show queued messages
smtpctl show queue

# Remove a stuck message by evpid (first field in show queue output)
smtpctl remove <evpid>

# Schedule immediate retry of all queued messages
smtpctl schedule all

# Reload a sender table without restarting (e.g. after editing from-map)
smtpctl update table newtownenergy_senders
smtpctl update table newtown_energy_senders

# Show stats
smtpctl show stats
```

## Config files

All files live under `/etc/smtpd/`:

- `/etc/smtpd.conf` — main OpenSMTPD config (written by manage install)
- `/etc/smtpd/mxroute-secrets` — MXroute credentials (mode 600)
- `/etc/smtpd/zeptomail-secrets` — ZeptoMail credentials (mode 600)
- `/etc/smtpd/newtownenergy-senders` — allowed `@newtownenergy.com` senders
- `/etc/smtpd/newtown-energy-senders` — allowed `@newtown.energy` senders
- `/etc/smtpd/test-send` — test script (installed by manage install)
