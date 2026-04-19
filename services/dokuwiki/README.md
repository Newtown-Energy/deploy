# dokuwiki

First, install dokuwiki on our server:

```
./dosh push wiki-server.newtown.energy
ssh wiki-server.newtown.energy
cd /opt/dokuwiki
./dosh install
```

Then, hook up the Caddy reverse proxy:
```
./dosh push newtown.energy
ssh newtown.energy
cd /opt/dokuwiki
./dosh install-caddy
```
