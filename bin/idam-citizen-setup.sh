#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

IDAM_URI="http://localhost:5000"

REDIRECTS=("http://localhost:3001/oauth2/callback" "http://localhost:3001/receiver")
REDIRECTS_STR=$(printf "\"%s\"," "${REDIRECTS[@]}")
REDIRECT_URI="[${REDIRECTS_STR%?}]"

PRL_CITIZEN_CLIENT_ID="prl-citizen-frontend"

PRL_CLIENT_SECRET=${PRL_CITIZEN_CLIENT_SECRET}

ROLES_ARR=("citizen")
ROLES_STR=$(printf "\"%s\"," "${ROLES_ARR[@]}")
ROLES="[${ROLES_STR%?}]"

AUTH_TOKEN=$(curl -s -H 'Content-Type: application/x-www-form-urlencoded' -XPOST "${IDAM_URI}/loginUser?username=${IDAM_ADMIN_USERNAME}&password=${IDAM_ADMIN_PASSWORD}" | docker run --rm --interactive stedolan/jq -r .api_auth_token)
HEADERS=(-H "Authorization: AdminApiAuthToken ${AUTH_TOKEN}" -H "Content-Type: application/json")

echo "Setup private law CITIZEN client"
# Create a client
curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${ROLES}"', "description": "'${PRL_CITIZEN_CLIENT_ID}'", "label": "'${PRL_CITIZEN_CLIENT_ID}'", "oauth2ClientId": "'${PRL_CITIZEN_CLIENT_ID}'", "oauth2ClientSecret": "'${PRL_CLIENT_SECRET}'", "oauth2RedirectUris": '${REDIRECT_URI}', "oauth2Scope": "openid profile roles", "onboardingEndpoint": "string", "onboardingRoles": '"${ROLES}"', "selfRegistrationAllowed": true}'


echo "Setup private law roles"
# Create roles in idam
for role in "${ROLES_ARR[@]}"; do
  curl -s -o /dev/null -XPOST ${IDAM_URI}/roles "${HEADERS[@]}" \
    -d '{"id": "'${role}'","name": "'${role}'","description": "'${role}'","assignableRoles": [],"conflictingRoles": []}'
done

echo "Setup private law client roles"
# Assign all the roles to the client
curl -s -o /dev/null -XPUT "${HEADERS[@]}" ${IDAM_URI}/services/${PRL_CITIZEN_CLIENT_ID}/roles -d "${ROLES}"

echo "Creating idam users"
./bin/idam-create-user.sh citizen aloknath.datta@cognizant.com Password12 citizen
./bin/idam-create-user.sh citizen aloknath.datta@hmcts.net Password12 citizen
echo "Idam setup complete"
