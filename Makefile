.PHONY: es-certs
es-certs:
	docker-compose -f docker-compose.setup.yml run --rm es_certs

.PHONY: es-keystore
es-keystore:
	docker-compose -f docker-compose.setup.yml run --rm es_keystore

.PHONY: setup
setup:
    @make es-certs
    @make es-keystore