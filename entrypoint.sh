#! /bin/bash

set -x

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

firebase_test_lab_output=$(gcloud beta firebase test android run --format=text $arg_spec 2>&1)

if [ $? -eq 0 ]; then
    echo "Test matrix successfully finished"
else
    status=$?
    echo "Test matrix exited abnormally with non-zero exit code: " $status
fi

echo $firebase_test_lab_output

firebase_test_lab_output=$(echo "$firebase_test_lab_output" | tr -d '\n')

report_url=$(echo "$firebase_test_lab_output" | \
                grep -Eo 'https://console\.firebase\.google\.com[^ ]+' | \
                sed 's/\.$//')
echo "Extracted Report URL: '$report_url'"
# Check if a URL was found
if [ -n "$report_url" ]; then
  echo "FTL_REPORT_URL=$report_url" >> $GITHUB_OUTPUT
else
  echo "FTL_ERROR_MESSAGE=\"No test results URL found in the text.\"" >> $GITHUB_OUTPUT
fi

gcp_url=$(echo "$firebase_test_lab_output" | \
             grep -Eo 'https://console\.developers\.google\.com/storage/browser[^ ]+' | \
             sed 's/\.$//')
echo "Extracted GCP URL: '$gcp_url'"
# Check if a URL was found
if [ -n "$gcp_url" ]; then
  echo "FTL_GCP_URL=$gcp_url" >> $GITHUB_OUTPUT
else
  echo "FTL_ERROR_MESSAGE=\"No test results URL found in the text.\"" >> $GITHUB_OUTPUT
fi

rm $service_account_file

echo "FTL_TEST_STATUS=$status" >> $GITHUB_OUTPUT

exit 0