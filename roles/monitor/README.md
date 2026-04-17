# roles/monitor

Installs the monitoring stack on a host:

- **victoria-metrics** — time series database (via apt)
- **perses** — dashboards and visualization (via apt, with auth bootstrap)

## Usage

```bash
# From the deploy/ directory:
runcible monitor roles/monitor/manage install
runcible monitor roles/monitor/manage uninstall
```

This uses rexer's before-only mode: `rexer.yml` sets `before: ./manage` and
`before-only: true`, so rexer runs `manage` locally with `LC_REXER_HOST` and
`LC_REXER_ARGS` set, then exits without connecting to the remote itself. The `manage`
script then calls rexer for each component.

The invocation works from any directory — runcible finds `monitor/manage` by path, not
by looking in the current directory.

## Required inventory hostvars

These must be set on each host in the `monitor` group:

| Hostvar | Description |
|---|---|
| `perses_port` | Port for perses to listen on (e.g. `8079`) |
| `perses_domains` | List of domains for the Caddy reverse proxy |
| `perses_encryption_key_cmd` | Command to retrieve the 32-char hex encryption key |
| `perses_admin_password_cmd` | Command to retrieve the admin user password |

The `_cmd` suffix tells runcible to execute the value as a shell command and pass the
result as `LC_PERSES_ENCRYPTION_KEY` / `LC_PERSES_ADMIN_PASSWORD`.

Generate an encryption key: `openssl rand -hex 16`

## Example inventory entry

```yaml
monitor:
  hosts:
    myhost:
      perses_port: 8079
      perses_domains:
        - perses.example.com
      perses_encryption_key_cmd: pass kv encryption-key box/myhost/perses
      perses_admin_password_cmd: pass box/myhost/perses | head -n 1
```

## Dependencies

- Caddy must be installed and running (manages the reverse proxy config)
- `perses` and `victoria-metrics` packages must be available in apt (from apt.jamesvasile.com)
- rexer >= 0.5.6 (for `before-only:` support and correct `LC_REXER_ARGS` parsing)

## What install does

1. Installs victoria-metrics via apt
2. Installs perses via apt
3. Bootstraps perses auth (starts with signup open → creates admin → restarts with signup disabled)
4. Writes Caddy reverse proxy config and reloads Caddy
