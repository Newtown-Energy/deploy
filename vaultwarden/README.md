# Vault Warden

```
./dosh push bromine.newtown.energy
ssh bromine.newtown.energy
cd /opt/vaultwarden
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

