# perses

Installs [Perses](https://github.com/perses/perses) dashboard server and configures Caddy to proxy it.

The manage script is host-agnostic. All host-specific configuration (port, domains) comes from
inventory hostvars passed by runcible. Do not invoke `manage` directly — use runcible so that
hostvars are resolved and passed correctly.

## Prerequisites

- `perses` apt package available in the apt repository
- Caddy running with `/etc/caddy/available` and `/etc/caddy/enabled` directories
- runcible with `ANSIBLE_INVENTORY` pointing to your inventory file

## Required inventory hostvars

Set these in your `inventory.yml` for each host running perses:

| Hostvar | Description | Example |
|---|---|---|
| `perses_port` | Port for perses to listen on | `8079` |
| `perses_domains` | List of domains to proxy | see below |
| `perses_encryption_key_cmd` | Command to retrieve the 32-byte AES encryption key | `npass kv encryption-key box/...` |
| `perses_admin_password_cmd` | Command to retrieve the initial admin password | `npass box/... \| head -n 1` |

Generate the key with `openssl rand -hex 16` (produces a 32-character hex string) and store it in pass before deploying.

Example:

```yaml
myhost:
  ansible_host: example.com
  ansible_user: root
  perses_port: 8079
  perses_domains:
    - perses.example.com
    - perses.example.org
```

## Install

Run from this directory (`deploy/perses/`), where direnv sets `ANSIBLE_INVENTORY`:

```sh
runcible newtown manage install
```

To deploy to all hosts in the `perses` inventory group:

```sh
runcible perses manage install
```

This will:
1. `apt install perses`
2. Write `/etc/perses/config.yaml` with the correct plugin paths
3. Set `PERSES_LISTEN=127.0.0.1:<perses_port>` in `/etc/perses/perses.env`
4. Restart perses and verify it started successfully
5. Write `/etc/caddy/available/perses.caddyfile` proxying the configured domains
6. Symlink it into `/etc/caddy/enabled/`
7. Reload Caddy

## Uninstall

```sh
runcible newtown manage uninstall
```

Removes the Caddy config and uninstalls the perses package. Data in `/var/lib/perses` is preserved.
