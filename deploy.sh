#! /bin/bash

BRANCH=$1
STAGE=''

# exit when any command fails
set -e

if [ "$BRANCH" == "develop" ] ; then
  STAGE='dev'
elif [ "$BRANCH" == "master" ] ; then
  STAGE='prod'
fi

if [ ! -z "$STAGE" ] ; then
  echo "Deploying new version of pocket ciso on $STAGE"

  echo "1. deploy aws resources"
  npm run deploy:resources -- --stage $STAGE
else
  echo "Stage not defined for '$BRANCH' branch, skipping..."
fi