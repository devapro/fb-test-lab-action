#! /bin/bash

status=0

if [ -z "$SERVICE_ACCOUNT" ]; then
  echo "Service account is required to authorize gcloud to access the Cloud Platform."
  status=2
  echo "FTL_TEST_STATUS=$status" >> $GITHUB_OUTPUT
  exit $status
fi


arg_spec="$1"
service_account_file=/opt/service_account.json

echo "$SERVICE_ACCOUNT" > $service_account_file

project_id=$(cat $service_account_file | jq -r ".project_id")

gcloud auth activate-service-account --key-file=$service_account_file
gcloud config set project $project_id

firebase_test_lab_output=$(eval "gcloud firebase test android run --format=text $arg_spec" 2>&1)

if [ $? -eq 0 ]; then
    echo "Test matrix successfully finished"
else
    status=$?
    echo "Test matrix exited abnormally with non-zero exit code: " $status
    echo "$firebase_test_lab_output"
    echo "$arg_spec"
fi

firebase_test_lab_output_line=$(echo "$firebase_test_lab_output" | tr -d '\n')

gcp_url=$(echo "$firebase_test_lab_output_line" | \
             grep -Eo 'https://console\.developers\.google\.com[^ ]+' | \
             head -n 1 | \
             sed 's/\]Test//' | sed 's/\.$//')
echo "Extracted GCP URL: '$gcp_url'"
# Check if a URL was found
if [ -n "$gcp_url" ]; then
  CLEANED_URL=$(echo "$gcp_url" | sed 's/%3A/:/g' | sed 's/%2F/\//g')
  # Remove any trailing newlines or spaces
  CLEANED_URL=$(echo "$CLEANED_URL" | tr -d '\n' | xargs)
  echo "FTL_GCP_URL=$CLEANED_URL" >> $GITHUB_OUTPUT
else
  echo "FTL_ERROR_MESSAGE=\"No test results URL found in the text.\"" >> $GITHUB_OUTPUT
fi

report_url=$(echo "$firebase_test_lab_output_line" | \
                grep -Eo 'https://console\.firebase\.google\.com[^ ]+' | \
                head -n 1 | \
                sed 's/\]Test//' | sed 's/\.$//')
echo "Extracted Report URL: '$report_url'"
# Check if a URL was found
if [ -n "$report_url" ]; then
  CLEANED_URL=$(echo "$report_url" | sed 's/%3A/:/g' | sed 's/%2F/\//g')
  # Remove any trailing newlines or spaces
  CLEANED_URL=$(echo "$CLEANED_URL" | tr -d '\n' | xargs)
  echo "FTL_REPORT_URL=$CLEANED_URL" >> $GITHUB_OUTPUT
else
  echo "FTL_ERROR_MESSAGE=\"No test results URL found in the text.\"" >> $GITHUB_OUTPUT
fi

rm $service_account_file

echo "FTL_TEST_STATUS=$status" >> $GITHUB_OUTPUT

exit 0