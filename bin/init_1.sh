#!/usr/bin/env bash

echo "Adding CCD role"
./bin/add-roles.sh
echo "Adding CCD user profiles"
./bin/add-ccd-user-profiles.sh
echo "Processing CCD definition"
./bin/process-and-import-ccd-definition.sh
echo "Adding role assignments"
./bin/add-role-assignments.sh
