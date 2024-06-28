CONTAINER_ENGINE ?= docker
REDIS_VERSION ?= v7.0.13
REDIS_SENTINEL_VERSION ?= v7.0.13
REDIS_EXPORTER_VERSION ?= v1.48.0

IMG ?= quay.io/opstree/redis:$(REDIS_VERSION)
EXPORTER_IMG ?= quay.io/opstree/redis-exporter:$(REDIS_EXPORTER_VERSION)
SENTINEL_IMG ?= quay.io/opstree/redis-sentinel:$(REDIS_SENTINEL_VERSION)

build-redis:
	${CONTAINER_ENGINE} build -t ${IMG} -f Dockerfile --build-arg REDIS_VERSION=${REDIS_VERSION} .

push-redis:
	${CONTAINER_ENGINE} push ${IMG}

build-redis-exporter:
	${CONTAINER_ENGINE} build -t ${EXPORTER_IMG} -f Dockerfile.exporter --build-arg REDIS_EXPORTER_VERSION=${REDIS_EXPORTER_VERSION} .

push-redis-exporter:
	${CONTAINER_ENGINE} push ${EXPORTER_IMG}

build-sentinel :
	${CONTAINER_ENGINE} build -t ${SENTINEL_IMG} -f Dockerfile.sentinel --build-arg REDIS_SENTINEL_VERSION=${REDIS_SENTINEL_VERSION} .

push-sentinel :
	${CONTAINER_ENGINE} push ${SENTINEL_IMG}

setup-standalone-server-compose:
	docker-compose -f docker-compose-standalone.yaml up -d

setup-cluster-compose:
	docker-compose -f docker-compose.yaml up -d
	docker-compose exec redis-master-3 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-1 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-2 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-3 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
