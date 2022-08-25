ARG ELASTIC_VERSION

FROM docker.elastic.co/logstash/logstash:${ELASTIC_VERSION}

USER root

# install ubuntu packages
RUN apt-get update  \
    && apt-get --yes install \
        git \
        bash \
        bash-completion \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=logstash:logstash ./logstash/entrypoint.sh /opt/setup/

RUN chmod +x /opt/setup/entrypoint.sh
ENTRYPOINT ["/opt/setup/entrypoint.sh"]

USER logstash