# Base System

There are some tools we're going to want on every server we deploy to.
We can install them in this package.


## Push

./dosh push <example.com> will send this script to a remote server.

You can also send it to many remote servers:

ansible-playbook -i ansible/inventory.yaml -e "playbook_hosts=HOSTSPEC" ansible/push.yaml

Replace HOSTSPEC with an ansible host specification.

Alternatively:

    adosh HOSTSPEC push

