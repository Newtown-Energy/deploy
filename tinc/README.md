# tinc

Tinc installation materials

## Install

Edit .env as needed.

```
/opt/tinc/dosh install
```

Now you have /etc/tinc, where you can put your network config dir

```
/opt/tinc/dosh config
```

## Push

`./dosh push remote.fqdn` will send a copy of this dir to
remote.fqdn:/opt.  From there you can ssh into the remote host and run
the installer.  It logs in as root, so make sure you have the right
ssh keys setup.

