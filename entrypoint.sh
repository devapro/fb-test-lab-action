#! /bin/bash

set -e

if [ -z "$SERVICE_ACCOUNT" ]; then
  echo "Service account is required to authorize gcloud to access the Cloud Platform."
  exit 2
fi

status=0
arg_spec=$1
service_account_file=/opt/service_account.json

echo "$SERVICE_ACCOUNT" > $service_account_file

project_id=$(cat $service_account_file | jq -r ".project_id")

gcloud auth activate-service-account --key-file=$service_account_file
gcloud config set project $project_id

firebase_test_lab_output=$(gcloud beta firebase test android run $arg_spec)

if [ $? -eq 0 ]; then
    echo "Test matrix successfully finished"
else
    status=$?
    echo "Test matrix exited abnormally with non-zero exit code: " $status
fi

echo "FIREBASE_TL_OUTPUT=$(echo $firebase_test_lab_output)" >> $GITHUB_ENV

rm $service_account_file

exit $status