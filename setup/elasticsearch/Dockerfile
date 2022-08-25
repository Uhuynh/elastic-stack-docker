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

COPY --chown=elasticsearch:root ./setup/elasticsearch /opt/setup

RUN mkdir -p /state && chown -R elasticsearch /state

RUN chmod +x /opt/setup/entrypoint.sh
RUN chmod +x /opt/setup/initialize.sh

ENTRYPOINT ["/opt/setup/entrypoint.sh"]

USER elasticsearch:root