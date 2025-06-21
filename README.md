# Newtown Deploy

Each directory is an app or service we might deploy somewhere.

The convention is to use /opt/servicename on the remotes for whatever
we need.

In each directory, there should be a dosh script.  `dosh push
[destination fqdn]` should send the contents to /opt/servicename on
the destination server.  Then, ssh to that server, cd to that dir and
do something like `./dosh install` or `./dosh install-caddy` to do the
needful on each server.  (Maybe we should ansiblize this, but for now
it's fine).

Each service should have sufficient scripts and instructions to support its
deploy.

Please don't put any secrets or configuration in git.  I am working on
solutions for those.

