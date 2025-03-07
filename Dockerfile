FROM google/cloud-sdk:latest

RUN apk update && apk add --no-cache jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]