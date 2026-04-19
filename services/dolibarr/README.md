# Dolibar

```
./dosh push bromine.newtown.energy
ssh bromine.newtown.energy
cd /opt/dolibarr
[EDIT .env]
./dosh install
exit

./dosh push newtown.energy
ssh newtown.energy
cd /opt/dolibarr
cp env.example .env
[EDIT .env]
./dosh install-caddy
exit
```
