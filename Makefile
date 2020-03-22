build-redis-image:
	docker build -t opstree/redis:dev -f Dockerfile .

build-redis-exporter-image:
	docker build -t opstree/redis-exporter:dev -f Dockerfile.exporter .

setup-standalone-server-compose:
	docker-compose up -f docker-compose-standalone.yaml -d

setup-cluster-compose:
	docker-compose up -f docker-compose.yaml -d
