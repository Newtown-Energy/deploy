# Seafile

Seafile is our document store.

# Install

## Install via Dosh

This works well if you're focused on a single host or using this dir
to install on a box that isn't in the inventory.

Send this repo to /opt/seafile on machines indicated in our ansible inventory:

```
./dosh push
```

```
ssh bromine.newtown.energy
/opt/seafile/dosh install
exit
./dosh push newtown.energy
ssh newtown.energy
/opt/seafile/dosh install-caddy
exit
```

## Install via Ansible

This works well if you're installing on multiple boxes.

```
adosh seafile push
arun seafile /opt/seafile/dosh install
adosh router push
arun router /opt/seafile/dosh install-caddy
```
