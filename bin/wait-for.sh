#!/usr/bin/env bash

NAME=$1
URL=$2

echo "Waiting for $NAME";
until curl -s -o /dev/null $2/health
do
  printf .
  sleep 1;
done

echo "it's ready!"
