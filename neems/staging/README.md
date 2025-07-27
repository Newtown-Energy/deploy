# Neems Staging, both Core and React

## Install

```bash
./dosh push <app server> <web router>
```

You can omit app server and web router to grab destinations from the ansible
inventory.  But if you don't have an ansible inventory or if you want an ad-hoc
destination, any routable name will do there.  An IP, a tailscale machine name,
a FQDN, whatever.

Then, ssh to those machines and do `dosh install` on the app server and `dosh
install-caddy` on the web router.

## Data Dir And Config

For the app server, this script creates a user, `neems-stging`, and a home dir,
`/var/lib/neems-staging`.

`dosh push` will send `.env` and `Rocket.toml` to `/opt/neems-core-staging`.
Then on the remote, `dosh install` will copy them to `/var/lib/neems-staging`.
Edit `.env` and `Rocket.toml` either here before you push or on the remote
side.  We need a better way to distribute config to machines, but for now this
is, imperfectly, what we have.

DB will end up in `/var/lib/neems-staging` by default.

When setting ports, note that you have to set it in two places.  In
`Rocket.toml` you set the listen port of the neems-core server.  In `.env` you
set the CADDY_DEST_PORT, which is the port Caddy will forward to.  These should
match unless you're doing something exotic.  By default, neems-core listens on
8000, but the examples here set it to 7272.

On the web router side, your static files will live in /opt/neems-staging and
caddy will serve them from there.
