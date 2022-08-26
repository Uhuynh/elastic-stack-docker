.PHONY: es-certs
es-certs:
	docker-compose -f docker-compose.setup.yml run --rm es_certs

.PHONY: setup
setup:
    @make es-certs