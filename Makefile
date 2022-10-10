REDIS_VERSION ?= v7.0.5
EXPORTER_VERSION ?= v1.44.0

build-redis-image:
	docker build -t quay.io/opstree/redis:$(REDIS_VERSION) -f Dockerfile .

build-redis-exporter-image:
	docker build -t opstree/redis-exporter:$(EXPORTER_VERSION) -f Dockerfile.exporter .

setup-standalone-server-compose:
	docker-compose -f docker-compose-standalone.yaml up -d

setup-cluster-compose:
	docker-compose -f docker-compose.yaml up -d
	docker-compose exec redis-master-3 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-1 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-2 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
	docker-compose exec redis-slave-3 /bin/bash -c "/usr/bin/setupMasterSlave.sh"
