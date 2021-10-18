#! /bin/bash

BRANCH=$1
STAGE=''

# exit when any command fails
set -e

if [ "$BRANCH" == "develop" ] ; then
  STAGE='dev'
  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_DEV
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_DEV
elif [ "$BRANCH" == "master" ] ; then
  STAGE='prod'
  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_PROD
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_PROD
fi

if [ ! -z "$STAGE" ] ; then
  echo "Deploying new version of football widget on $STAGE"

  echo "1. set aws credentials"
 npm run post_deploy --provider aws --key $AWS_ACCESS_KEY_ID --secret $AWS_SECRET_ACCESS_KEY --overwrite
  echo "2. deploy aws resources"
  npm run deploy:resources -- --stage $STAGE
else
  echo "Stage not defined for '$BRANCH' branch, skipping..."
fi