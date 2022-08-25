ARG ELASTIC_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}

USER root

# install ubuntu packages
RUN apt-get update  \
    && apt-get --yes install --fix-missing \
        git \
        bash \
        bash-completion \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=elasticsearch:elasticsearch ./elasticsearch/entrypoint.sh /opt/setup/

RUN chmod +x /opt/setup/entrypoint.sh
ENTRYPOINT ["/opt/setup/entrypoint.sh"]

USER elasticsearch