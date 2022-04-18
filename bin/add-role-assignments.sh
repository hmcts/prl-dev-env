#!/usr/bin/env bash

# Note that currently the role assignments are created in the role assignment database directly
# due to restrictions in the rules engine of the Role Assignment Service APIs.
# The `utils/am-role-assignments.json` can be modified to add further role assignments to users.

set -eu

dir=$(dirname ${0})

jq -c '(.[])' ${dir}/utils/am-role-assignments.json | while read user; do

  override=$(jq -r '.overrideAll' <<< $user)
  if [ $override == 'true' ]; then
    echo "Removing all existing role assignments for user ${IDAM_SYSTEM_UPDATE_USERNAME}"
    psql -h localhost -p 5050 -d role_assignment -U prl -c "DELETE FROM role_assignment WHERE actor_id = '${IDAM_SYSTEM_UPDATE_USERNAME}'" -q
  fi
  echo "done role assignment removal"
  jq -c '(.roleAssignments[])' <<< $user | while read assignment; do
    roleType=$(jq -r '.roleType' <<< $assignment)
    roleName=$(jq -r '.roleName' <<< $assignment)
    grantType=$(jq -r '.grantType' <<< $assignment)
    roleCategory=$(jq -r '.roleCategory' <<< $assignment)
    classification=$(jq -r '.classification' <<< $assignment)
    readOnly=$(jq -r '.readOnly' <<< $assignment)
    attributes=$(jq -r '.attributes | tostring' <<< $assignment)

    authorisations=$(jq -r 'if .authorisations | length > 0 then "'"'"'{" + (.authorisations | join(",")) + "}'"'"'" else null end' <<< $assignment)

    echo "Creating '${roleName}' assignment of type '${roleType}' for user ${IDAM_SYSTEM_UPDATE_USERNAME}"
    ${dir}/am-add-role-assignment.sh ${IDAM_SYSTEM_UPDATE_USERNAME} $roleType $roleName $classification $grantType $roleCategory $readOnly $attributes $authorisations
  done
  echo
done