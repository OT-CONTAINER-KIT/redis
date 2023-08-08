REDIS_VERSION ?= v7.0.12
SENTINEL_VERSION ?= v7.0.12
EXPORTER_VERSION ?= v1.48.0

IMG ?= quay.io/opstree/redis:$(REDIS_VERSION)
EXPORTER_IMG ?= quay.io/opstree/redis-exporter:$(EXPORTER_VERSION)
SENTINEL_IMG ?= quay.io/opstree/redis-sentinel:$(SENTINEL_VERSION)

build-redis:
	docker build -t ${IMG} -f Dockerfile .

push-redis:
	docker push ${IMG}

build-redis-exporter:
	docker build -t ${EXPORTER_IMG} -f Dockerfile.exporter .

push-redis-exporter:
	docker push ${EXPORTER_IMG}

build-sentinel :
	docker build -t ${SENTINEL_IMG} -f Dockerfile.sentinel .

push-sentinel :
	docker push ${SENTINEL_IMG}

setup-standalone-server-compose:
	docker-compose -f docker-compose-standalone.yaml up -d

setup-cluster-compose:
	docker-compose -f docker-compose.yaml up -d
	docker-compose exec redis-master-3 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-1 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-2 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-3 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
