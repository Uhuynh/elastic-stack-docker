# elastic-stack-docker
Elasticsearch - Kibana - Logstash on Docker


- Main idea is to start a simple ready-to-deploy ELK stack.
- The project is built based on the famous repository 
[deviantony/docker-elk](https://github.com/deviantony/docker-elk) with some added features:
  - Stack has 3 Elasticsearch nodes - 1 Logstash node - 1 Kibana node
  - Use a single configuration file for all Elasticsearch nodes
  - Persist Certificate Authority (CA) and Elasticsearch nodes' certificates and keys
  - Encrypt internode communication with TLS by default
  - Use `.env` file to configure stack parameters
  - Possible to add custom commands in `entrypoint.sh` of each node.
  - Create required roles and users by default
  - Configure Persistent Queue and Dead Letter Queue for Logstash pipelines

---
## Table of contents
1. [Setup](#1-setup)  
   1.1. [Prepare tools](#11-prepare-tools)  
   1.2. [Clone project](#12-clone-project)  
   1.3. [Initialize environment variables](#13-initialize-environment-variables)  
   1.4. [Configrue virtual memory](#14-configure-virtual-memory)  
2. [Generate nodes certificates](#2-generate-nodes-certificates)
3. [Bring up the stack](#3-bring-up-the-stack)
4. [Verify the stact](#4-verify-the-stack)
5. [Clean up](#5-clean-up)
---

# 1. Setup

## 1.1. Prepare tools
- For Windows: Start `Docker Desktop for Windows`
- Check if `docker` and `docker-compose` are installed on the machine:
    ````shell
    $ docker --version
    Docker version 20.10.13, build a224086
    $ docker-compose --version
    docker-compose version 1.29.2, build 5becea4c
    ````
- Make sure to have at least 4GB RAM

## 1.2. Clone project
````shell
$ git clone https://github.com/Uhuynh/elastic-stack-docker.git
````

## 1.3. Initialize environment variables
- In the project root directory, search for `.env` file
- Fill in the credentials in `.env` file with random strings of your choice

## 1.4. Configure virtual memory
- In your command line (`cmd`)
    ````shell
    $ wsl -d docker-desktop
    NBDJE227:~# sysctl -w vm.max_map_count=262144
    vm.max_map_count = 262144
    ````
- To [official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html)

# 2. Generate nodes certificates
- Run `make es-certs` or `docker-compose -f docker-compose.setup.yml run --rm es_certs` to 
generate a Certificate Authority (CA) and node certificates for Elasticsearch in PEM format.
  - The service simply exits if certificates already exist in folder `./certs`
  - The results should look like below:
    ```text
    project
    │   README.md   
    └───certs
    │   └───ca
    │       │   ca.crt
    │       │   ca.key
    │   └───es01
    │       │   es01.crt
    │       │   es01.key
    │   └───es02
    │       │   es02.crt
    │       │   es02.key
    │   └───es03
    │       │   es03.crt
    │       │   es03.key
    │   instances.yml   
    ```
- The generated CA is used immediately to sign Elasticsearch node certificates, which are 
saved under `es01`, `es02`, and `es03`.
- The node certificates in `es01`, `es02`, and `es03`are used by Elasticsearch nodes to 
authenticates itself and communicate with each other in the cluster.
  - The usage is defined in Elasticsearch configuration settings: `./elasticsearch/config/elasticsearch.yml`
- The `ca.crt` is used by Logstash and Kibana to authenticates themselves when
communicating with Elasticsearch nodes.
  - The usage in defined in Kibana and Logstash configuration settings:
    - `./logstash/config/logstash.yml`
    - `./kibana/config/kibana.yml`
- This is required by default in order to enable security (TLS and HTTPS) and start the
stack in production mode.
- To [official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/8.1/security-basic-setup.html)

# 3. Bring up the stack
- Execute `docker-compose up -d`
- This will bring up 6 containers, including a `setup` container, which initializes the
`logstash_internal`, `logstash_system`, and `kibana_system` users inside Elasticsearch with the
values of the passwords defined in `.env`
  - `logstash_internal` user: necessary to create / write indices to Elasticsearch. 
To [official documentation](https://www.elastic.co/guide/en/logstash/7.17/ls-security.html#ls-http-auth-basic)
  - `logstash_system` user: collect Logstash monitoring data
  - `kibana_system` user: collect Kibana monitoring data

# 4. Verify the stack
- Give the stack a minute to start.
- To verify the setup, go to your browser: `http://localhost:5601`
- Login with user `elastic` and password `ELASTIC_PASSWORD` as defined in your `.env` file
![login-page][login-page]

- Navigate to `Management -> Stack Management -> Users` to see the users that were iniitialized.
![users-page][users-page]

# 5. Clean up
To clean up your environment (containers, volumes) run:
```shell
$ docker-compose down --volumes --remove-orphans
$ docker system prune
```

[login-page]: markdown/login_page.png
[users-page]: markdown/user-page.png
