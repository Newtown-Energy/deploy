# tinc

Tinc installation materials

## Install

This is for local install, so put this dir on the machine you're
installing tinc on.  `./dosh push TARGET` will put it in /opt/tinc on
the `TARGET` machine.

Edit `/opt/tinc/.env` as needed.

```
/opt/tinc/dosh install
```

Now you have /etc/tinc, where you can put your network config dir

```
/opt/tinc/dosh config
```

You might want to backup the drive or save the private host key in a
vault somewhere so you don't have to reprovision for VPN access in
case of disaster.

At this point, you have a valid tinc config and should be able to ping
yourself over the tinc network.

Now you need to exchange keys with some other nodes.

## Push

`./dosh push remote.fqdn` will send a copy of this dir to
remote.fqdn:/opt/tinc.  From there you can ssh into the remote host and run
the installer.  It logs in as root, so make sure you have the right
ssh keys setup.

