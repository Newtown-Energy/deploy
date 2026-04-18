# roles/monitored

Installs the metrics collection stack on a host:

- **prometheus-node-exporter** — exposes host metrics on `localhost:9100`
- **vmagent** — scrapes node-exporter and forwards metrics to victoria-metrics

## Usage

```bash
runcible monitored roles/monitored/manage install
runcible monitored roles/monitored/manage uninstall
```

## Required inventory hostvars

| Hostvar | Description |
|---|---|
| `victoria_metrics_url` | remoteWrite URL for vmagent (e.g. `http://monitor-host:8428/api/v1/write`) |

## Example inventory entry

```yaml
monitored:
  hosts:
    myhost:
      victoria_metrics_url: http://monitor.example.com:8428/api/v1/write
```

## Dependencies

- `prometheus-node-exporter` and `vmagent` packages must be available in apt (from apt.jamesvasile.com)

## What install does

1. Installs prometheus-node-exporter and vmagent via apt
2. Sets `REMOTE_WRITE_URL` in `/etc/vmagent/vmagent.env`
3. Restarts vmagent

The vmagent package ships with a scrape config that targets `localhost:9100` (node-exporter's default port), so no scrape config changes are needed.
