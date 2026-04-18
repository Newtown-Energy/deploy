# vmagent

Installs and configures vmagent to scrape prometheus-node-exporter and forward metrics to victoria-metrics.

## Usage

### Via runcible (uses inventory hostvars)

```bash
# From deploy/ directory
runcible monitored vmagent/manage install
runcible monitored vmagent/manage uninstall
runcible monitored vmagent/manage status
```

### Via rexer directly

```bash
rexer --sudo \
  -E VICTORIA_METRICS_URL=http://monitor-host:8428/api/v1/write \
  -C VICTORIA_METRICS_USERNAME="pass kv username box/myhost/victoria-metrics" \
  -C VICTORIA_METRICS_PASSWORD="pass box/myhost/victoria-metrics | head -n 1" \
  user@host \
  vmagent/manage install
```

### Called from roles/monitored/manage

```bash
rexer "$HOST" "$DEPLOY_DIR/vmagent/manage" install
```

## Required inventory hostvars

| Hostvar | Description |
|---|---|
| `victoria_metrics_url` | remoteWrite URL (e.g. `http://monitor-host:8428/api/v1/write`) |
| `victoria_metrics_username_cmd` | Command to retrieve the HTTP basic auth username |
| `victoria_metrics_password_cmd` | Command to retrieve the HTTP basic auth password |

## What install does

1. Installs vmagent via apt
2. Sets `REMOTE_WRITE_URL` and `VM_REMOTE_USERNAME` in `/etc/vmagent/vmagent.env`
3. Writes the password to `/etc/vmagent/remote-password` (mode 640, owned by vmagent)
4. Restarts vmagent and verifies it starts and serves `/health`

## Notes

- Requires vmagent >= 1.140.0-3 (adds auth support and `/var/lib/vmagent` data dir)
- Default scrape config targets `localhost:9100` (prometheus-node-exporter)
- Password is kept out of `ps aux` via `-remoteWrite.basicAuth.passwordFile`
- vmagent's persistent queue is stored in `/var/lib/vmagent`
