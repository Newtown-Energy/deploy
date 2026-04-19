# victoria-metrics

Installs and configures victoria-metrics with HTTP basic auth and public listen address.

## Usage

```bash
# Standalone (from deploy/ directory)
runcible monitor victoria-metrics/manage install
runcible monitor victoria-metrics/manage uninstall

# Check status and which hosts are sending data
runcible monitor victoria-metrics/manage status

# Called from roles/monitor/manage
rexer "$HOST" "$DEPLOY_DIR/victoria-metrics/manage" install
```

## Required inventory hostvars

| Hostvar | Description |
|---|---|
| `victoria_metrics_username_cmd` | Command to retrieve the HTTP basic auth username |
| `victoria_metrics_password_cmd` | Command to retrieve the HTTP basic auth password |

## What install does

1. Installs victoria-metrics via apt
2. Sets `LISTEN_ADDR=:8428` in `/etc/victoria-metrics/victoria-metrics.env` (listens on all interfaces)
3. Sets `VM_HTTP_USERNAME` in the env file
4. Writes the password to `/etc/victoria-metrics/http-password` (mode 640, owned by victoria-metrics)
5. Restarts victoria-metrics and verifies it starts and accepts auth

## Notes

- Requires victoria-metrics >= 1.140.0-2 (adds env file and file:// password support)
- Password is kept out of `ps aux` via `-httpAuth.password=file://` in the service unit
- Default package config binds to `127.0.0.1:8428`; this deploy opens it to `:8428`
