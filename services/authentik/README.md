# Authentik

We're running this via docker with all data in this dir.

## Install

```
cd /opt/authentik
./dosh install
```

Then, be sure to customize .env if needed.

Finally, start authentik like any other systemd service.

Note: This doesn't set up the reverse proxy you'll need to make it
web-accessible.  Or the vpn you'll need to make it vpn-accessible.

## Push

`./dosh push remote.fqdn` will send a copy of this dir to
remote.fqdn:/opt.  From there you can ssh into the remote host and run
the installer.  It logs in as root, so make sure you have the right
ssh keys setup.

