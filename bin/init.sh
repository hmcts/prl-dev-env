#!/usr/bin/env bash

az keyvault secret show --vault-name prl-aat -o tsv --query value --name prl-local-env-config | base64 -d > .env

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

API_DIR=./prl-ccd-definition

az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
az acr login --name hmctsprivate --subscription 8999dec3-0104-4a27-94ee-6588559729d1

[[ -d $API_DIR ]] || git clone git@github.com:hmcts/prl-ccd-definitions.git

#docker-compose stop
docker-compose pull
docker-compose up -d idam-api fr-am fr-idm idam-web-public shared-db

./bin/wait-for.sh "IDAM" http://localhost:5000

echo "Starting IDAM set up"
./bin/idam-setup.sh
echo "IDAM set up done"

docker-compose up --build -d

./bin/wait-for.sh "CCD definition store" http://localhost:4451

echo "Adding CCD role"
./bin/add-roles.sh
echo "Adding CCD user profiles"
./bin/add-ccd-user-profiles.sh
echo "Processing CCD definition"
./bin/process-and-import-ccd-definition.sh
echo "Adding role assignments"
./bin/add-role-assignments.sh
