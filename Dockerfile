FROM bitnami/kubectl

USER root
RUN apt-get update && apt-get install -y jq

COPY assets /opt/resource
