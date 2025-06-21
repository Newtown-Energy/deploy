# Vault Warden

```
./dosh push bromine.newtown.energy
ssh bromine.newtown.energy
cd /opt/vaultwarden
[EDIT .env]
./dosh install
exit

./dosh push newtown.energy
ssh newtown.energy
cd /opt/vaultwarden
cp env.example .env
[EDIT .env]
./dosh install-caddy
exit
```

Note that the vaultwarden instance reads from .env at runtime but the
Caddy one does not, so if you change the .env file, you'll have to
`./dosh install-caddy` again.
