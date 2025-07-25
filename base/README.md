# Base System

There are some tools we're going to want on every server we deploy to.
We can install them in this package.

# Install

## Via ansible

```
ap push
adosh all install
```
## Via dosh

This is good for installing on a host that isn't in your ansible inventory.

# Push

./dosh push <example.com> will send this script to a remote server.

You can also send it to many remote servers:

ansible-playbook -i ansible/inventory.yaml -e "playbook_hosts=HOSTSPEC" ansible/push.yaml

Replace HOSTSPEC with an ansible host specification.

Alternatively:

    adosh HOSTSPEC push


# lineinfile

We have a script here that is meant to mimic ansible's lineinfile.
Running `dosh install` will copy it to /usr/local/bin.
