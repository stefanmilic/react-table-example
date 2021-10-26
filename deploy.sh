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
  ./node_modules/.bin/sls config credentials --provider aws --key $AWS_ACCESS_KEY_ID --secret $AWS_SECRET_ACCESS_KEY --overwrite
  echo "2. deploy aws resources"
  npm run deploy:resources -- --stage $STAGE
  echo "3. uploading static assets to football-widget-test-$STAGE"
   aws s3 sync .build/ s3://football-widget-test-$STAGE --delete --acl public-read --region eu-west-1
  echo "4. getting cloudfront distribution id"
  CLOUDFRONT_DISTRIBUTION_ID="$(aws cloudfront list-distributions --query "DistributionList.Items[].{id: Id, OriginDomainName: Origins.Items[0].DomainName}[?contains(OriginDomainName, 'football-widget-test-prod')] | [0].id" --out text)"
  echo "5. cloudfront invalidation"
  aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} --paths "/*"
else
  echo "Stage not defined for '$BRANCH' branch, skipping..."
fi