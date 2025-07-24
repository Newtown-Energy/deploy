#!/bin/bash

[ -d /opt/openproject/pgdata ] || sudo mkdir -p /opt/openproject/pgdata
[ -d /opt/openproject/assets ] || sudo mkdir -p /opt/openproject/assets

docker run -p 4962:80 --name openproject \
  -e OPENPROJECT_HOST__NAME=proj.newtown.energy \
  -e OPENPROJECT_SECRET_KEY_BASE=66IS2cTiqrHSfW83Rt98UJHy63QdgPdHset32 \
  -e OPENPROJECT_HTTPS=true \
  -v /opt/openproject/pgdata:/var/openproject/pgdata \
  -v /opt/openproject/assets:/var/openproject/assets \
  openproject/openproject:16
