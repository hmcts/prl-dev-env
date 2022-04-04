#!/bin/bash
## Usage: ./idam-create-user.sh roles email [password] [group] [surname] [forename]
##
## Options:
##    - role: Comma-separated list of roles. Roles must exist in IDAM (i.e `caseworker-probate,caseworker-probate-solicitor`)
##    - email: Email address
##    - password: User's password. Default to `Pa55word11`. Weak passwords that do not match the password criteria by SIDAM will cause use creation to fail, and such failure may not be expressly communicated to the user.
##    - group: caseworker or citizen. Defaults to `caseworker`
##    - surname: Last name. Default to `Test`.
##    - forename: First name. Default to `User`.
##

rolesStr=$1
email=$2
password=${3:-Pa55word11}
group=${4:-caseworker}
surname=${5:-Test}
forename=${6:-User}

if [ -z "$rolesStr" ]
  then
    echo "Usage: ./idam-create-user.sh roles [email] [password] [group] [surname] [forename]"
    exit 1
fi

IFS=',' read -ra roles <<< "$rolesStr"

echo "Creating user $email"

# Build roles JSON array
rolesJson="["
firstRole=true
for i in "${roles[@]}"; do
  if [ "$firstRole" = false ] ; then
    rolesJson="${rolesJson},"
  fi
  rolesJson=''${rolesJson}'{"code":"'${i}'"}'
  firstRole=false
done
rolesJson="${rolesJson}]"
curl -s -o /dev/null -XDELETE http://localhost:5000/testing-support/accounts/$email

curl -s -o /dev/null -XPOST \
  http://localhost:5000/testing-support/accounts \
  -H "Content-Type: application/json" \
  -d '{"email":"'${email}'","forename":"'${forename}'","surname":"'${surname}'","password":"'${password}'","levelOfAccess":1, "roles": '${rolesJson}', "userGroup": {"code": "'$group'"}}'