ARG ELASTIC_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}

USER root

COPY --chown=elasticsearch:root ./setup/elasticsearch /opt/setup

RUN mkdir -p /state && chown -R elasticsearch /state

RUN chmod +x /opt/setup/entrypoint.sh
RUN chmod +x /opt/setup/initialize.sh

ENTRYPOINT ["/opt/setup/entrypoint.sh"]

USER elasticsearch:root