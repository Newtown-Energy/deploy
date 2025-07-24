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

Once done, you need to add email settings.  Run it once to generate
./data tree, then add this to the bottom of `data/seafile/seafile/conf/seahub_settings.py`:

EMAIL_USE_TLS = True
EMAIL_USE_SSL = False
EMAIL_HOST = 'smtp.zeptomail.com'
EMAIL_PORT = 587
EMAIL_HOST_USER = 'emailapikey'
EMAIL_HOST_PASSWORD = ZEPTO_PASSWORD
DEFAULT_FROM_EMAIL = 'bot@newtown.energy'
SERVER_EMAIL = 'bot@newtown.energy'

Replace ZEPTO_PASSWORD with the email api key password.

Then in `data/seafile/seafile/conf/seafevents.conf` make sure [SEAHUB
EMAIL] looks like this:


[SEAHUB EMAIL]
enabled = true
host = smtp.zeptomail.com
port = 587
username = emailapikey
password = ZEPTO_PASSWORD
use_ssl = false
use_tls = true
sender = bot@newtown.energy
from_email = bot@newtown.energy

Again, replace ZEPTO_PASSWORD with the email api key password.

## Install via Ansible

This works well if you're installing on multiple boxes.

```
adosh seafile push
arun seafile /opt/seafile/dosh install
adosh router push
arun router /opt/seafile/dosh install-caddy
```
