#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

IDAM_URI="http://localhost:5000"

REDIRECTS=("http://localhost:3000/oauth2/callback")
REDIRECTS_STR=$(printf "\"%s\"," "${REDIRECTS[@]}")
REDIRECT_URI="[${REDIRECTS_STR%?}]"

CCD_REDIRECTS=("http://ccd-data-store-api/oauth2redirect")
CCD_REDIRECTS_STR=$(printf "\"%s\"," "${CCD_REDIRECTS[@]}")
CCD_REDIRECT_URI="[${CCD_REDIRECTS_STR%?}]"

AM_REDIRECTS=("http://am-role-assignment-service:4096/oauth2redirect")
AM_REDIRECTS_STR=$(printf "\"%s\"," "${AM_REDIRECTS[@]}")
AM_REDIRECT_URI="[${AM_REDIRECTS_STR%?}]"

PRL_COS_CLIENT_ID="prl_cos_api"
PRL_DGS_CLIENT_ID="prl_dgs_api"
XUI_CLIENT_ID="xuiwebapp"

PRL_CLIENT_SECRET=${PRL_CLIENT_SECRET}
XUI_CLIENT_SECRET=${OAUTH2_CLIENT_SECRET}

ROLES_ARR=("ccd-import" "caseworker-privatelaw" "caseworker" "caseworker-privatelaw-courtadmin" "caseworker-privatelaw-systemupdate" "caseworker-privatelaw-superuser" "caseworker-privatelaw-la" "caseworker-privatelaw-judge" "caseworker-privatelaw-solicitor")
ROLES_STR=$(printf "\"%s\"," "${ROLES_ARR[@]}")
ROLES="[${ROLES_STR%?}]"

XUI_ROLES_ARR=("XUI-Admin" "XUI-SuperUser" "caseworker" "caseworker-privatelaw" "caseworker-privatelaw-courtadmin" "caseworker-privatelaw-systemupdate" "caseworker-privatelaw-superuser" "caseworker-privatelaw-la" "caseworker-privatelaw-judge" "caseworker-privatelaw-solicitor")
XUI_ROLES_STR=$(printf "\"%s\"," "${XUI_ROLES_ARR[@]}")
XUI_ROLES="[${XUI_ROLES_STR%?}]"

AUTH_TOKEN=$(curl -s -H 'Content-Type: application/x-www-form-urlencoded' -XPOST "${IDAM_URI}/loginUser?username=${IDAM_ADMIN_USERNAME}&password=${IDAM_ADMIN_PASSWORD}" | docker run --rm --interactive stedolan/jq -r .api_auth_token)
HEADERS=(-H "Authorization: AdminApiAuthToken ${AUTH_TOKEN}" -H "Content-Type: application/json")

echo "Setup private law COS client"
# Create a client
curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${ROLES}"', "description": "'${PRL_COS_CLIENT_ID}'", "label": "'${PRL_COS_CLIENT_ID}'", "oauth2ClientId": "'${PRL_COS_CLIENT_ID}'", "oauth2ClientSecret": "'${PRL_CLIENT_SECRET}'", "oauth2RedirectUris": '${REDIRECT_URI}', "oauth2Scope": "openid profile roles", "onboardingEndpoint": "string", "onboardingRoles": '"${ROLES}"', "selfRegistrationAllowed": true}'

# echo "Setup private law DGS client"
# Create a client
# curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
#  -d '{ "activationRedirectUrl": "", "allowedRoles": '"${ROLES}"', "description": "'${PRL_DGS_CLIENT_ID}'", "label": "'${PRL_DGS_CLIENT_ID}'", "oauth2ClientId": "'${PRL_DGS_CLIENT_ID}'", "oauth2ClientSecret": "'${PRL_CLIENT_SECRET}'", "oauth2RedirectUris": '${REDIRECT_URI}', "oauth2Scope": "openid profile roles", "onboardingEndpoint": "string", "onboardingRoles": '"${ROLES}"', "selfRegistrationAllowed": true}'

echo "Setup xui client"
# Create a client
curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${XUI_ROLES}"', "description": "'${XUI_CLIENT_ID}'", "label": "'${XUI_CLIENT_ID}'", "oauth2ClientId": "'${XUI_CLIENT_ID}'", "oauth2ClientSecret": "'${XUI_CLIENT_SECRET}'", "oauth2RedirectUris": '${REDIRECT_URI}', "oauth2Scope": "profile openid roles manage-user create-user search-user", "onboardingEndpoint": "string", "onboardingRoles": '"${XUI_ROLES}"', "selfRegistrationAllowed": true}'

echo "Setup ccd data store client"
curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${ROLES}"', "description": "ccd_data_store_api", "label": "ccd_data_store_api", "oauth2ClientId": "ccd_data_store_api", "oauth2ClientSecret": "'${OAUTH2_CLIENT_SECRET}'", "oauth2RedirectUris": '${CCD_REDIRECT_URI}', "oauth2Scope": "profile openid roles manage-user", "onboardingEndpoint": "string", "onboardingRoles": '"${ROLES}"', "selfRegistrationAllowed": true}'

echo "Setup access management client"
curl -s -o /dev/null -XPOST "${HEADERS[@]}" ${IDAM_URI}/services \
 -d '{ "activationRedirectUrl": "", "allowedRoles": '"${ROLES}"', "description": "am_role_assignment", "label": "am_role_assignment", "oauth2ClientId": "am_role_assignment", "oauth2ClientSecret": "am_role_assignment_secret", "oauth2RedirectUris": '${AM_REDIRECT_URI}', "oauth2Scope": "profile openid roles search-user", "onboardingEndpoint": "string", "onboardingRoles": '"${ROLES}"', "selfRegistrationAllowed": true}'

echo "Setup private law roles"
# Create roles in idam
for role in "${ROLES_ARR[@]}"; do
  curl -s -o /dev/null -XPOST ${IDAM_URI}/roles "${HEADERS[@]}" \
    -d '{"id": "'${role}'","name": "'${role}'","description": "'${role}'","assignableRoles": [],"conflictingRoles": []}'
done

echo "Setup xui roles"
# Create roles in idam
for role in "${XUI_ROLES_ARR[@]}"; do
  curl -s -o /dev/null -XPOST ${IDAM_URI}/roles "${HEADERS[@]}" \
    -d '{"id": "'${role}'","name": "'${role}'","description": "'${role}'","assignableRoles": [],"conflictingRoles": []}'
done

echo "Setup private law client roles"
# Assign all the roles to the client
curl -s -o /dev/null -XPUT "${HEADERS[@]}" ${IDAM_URI}/services/${PRL_COS_CLIENT_ID}/roles -d "${ROLES}"

echo "Setup xui client roles"
# Assign all the roles to the client
curl -s -o /dev/null -XPUT "${HEADERS[@]}" ${IDAM_URI}/services/${XUI_CLIENT_ID}/roles -d "${XUI_ROLES}"

echo "Creating idam users"
./bin/idam-create-user.sh caseworker,caseworker-privatelaw,caseworker-privatelaw-solicitor,caseworker-privatelaw-systemupdate,caseworker-privatelaw-courtadmin,caseworker-privatelaw-bulkscan,caseworker-privatelaw-superuser,caseworker-privatelaw-courtadmin-la $IDAM_CASEWORKER_USERNAME $IDAM_CASEWORKER_PASSWORD caseworker
./bin/idam-create-user.sh caseworker,caseworker-privatelaw,caseworker-privatelaw-courtadmin $IDAM_TEST_CASEWORKER_USERNAME $IDAM_TEST_CASEWORKER_PASSWORD caseworker
./bin/idam-create-user.sh caseworker,caseworker-privatelaw,caseworker-privatelaw-solicitor $IDAM_TEST_SOLICITOR_USERNAME $IDAM_TEST_SOLICITOR_PASSWORD caseworker
./bin/idam-create-user.sh ccd-import $DEFINITION_IMPORTER_USERNAME $DEFINITION_IMPORTER_PASSWORD Default
./bin/idam-create-user.sh caseworker,caseworker-privatelaw,caseworker-privatelaw-systemupdate $IDAM_SYSTEM_UPDATE_USERNAME $IDAM_SYSTEM_UPDATE_PASSWORD caseworker
./bin/idam-create-user.sh caseworker $CCD_SYSTEM_UPDATE_USERNAME $CCD_SYSTEM_UPDATE_PASSWORD caseworker
echo "Idam setup complete"
