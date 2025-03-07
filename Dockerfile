FROM google/cloud-sdk:latest

RUN apt update && apt install -y jq

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]