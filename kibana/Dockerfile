ARG ELASTIC_VERSION

FROM docker.elastic.co/kibana/kibana:${ELASTIC_VERSION}

USER root

# install ubuntu packages
RUN apt-get update  \
    && apt-get --yes install --fix-missing \
        python3.8 \
        python3-distutils  \
        python3-pip  \
        python3-apt \
        git \
        bash \
        bash-completion \
    && rm -rf /var/lib/apt/lists/*

# add dje root certificate
COPY ./certs/MUC-DJE-CA.crt /MUC-DJE-CA.crt
RUN cp /MUC-DJE-CA.crt /usr/local/share/ca-certificates/MUC-DJE-CA.crt && update-ca-certificates

# install pip, setuptools and libsecrets
RUN pip config set global.trusted-host "pypi.org files.pythonhosted.org pypi.python.org" && \
    pip config set global.cert /usr/local/share/ca-certificates/MUC-DJE-CA.crt

RUN pip install -U pip setuptools

RUN pip install PyYAML && pip install git+https://oauth2:zxZFXHyLzxw5TxoBzufg@git.cloud.dje-intern.de/shared/libsecrets.git@v0.1.3#egg=libsecrets

COPY --chown=kibana:kibana ./kibana/entrypoint.sh /opt/setup/

RUN chmod +x /opt/setup/entrypoint.sh
ENTRYPOINT ["/opt/setup/entrypoint.sh"]

USER kibana