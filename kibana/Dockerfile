ARG ELASTIC_VERSION

FROM docker.elastic.co/kibana/kibana:${ELASTIC_VERSION}

USER root

# install ubuntu packages
RUN apt-get update  \
    && apt-get --yes install --fix-missing \
        git \
        bash \
        bash-completion \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=kibana:kibana ./kibana/entrypoint.sh /opt/setup/

RUN chmod +x /opt/setup/entrypoint.sh
ENTRYPOINT ["/opt/setup/entrypoint.sh"]

USER kibana