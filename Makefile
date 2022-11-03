run-test: prepare-test
	docker-compose -f docker-test/service/docker-compose-service.yml up

stop-test:
	docker-compose -f docker-test/service/docker-compose-service.yml down
	rm -r docker-test/service/test-classes

run-test-hazelcast: prepare-test
	docker-compose -f docker-test/service/docker-compose-service-hazelcast.yml up

stop-test-hazelcast:
	docker-compose -f docker-test/service/docker-compose-service-hazelcast.yml down

run-test-flows: prepare-test
	docker-compose -f docker-test/service/docker-compose-service-flows.yml up

stop-test-flows:
	docker-compose -f docker-test/service/docker-compose-service-flows.yml down

run-test-sidecar:
	docker-compose -f docker-test/sidecar/docker-compose.yml up

stop-test-sidecar:
	docker-compose -f docker-test/sidecar/docker-compose.yml down

prepare-test:
	mkdir -p docker-test/service/test-classes/net/loginbuddy/config/loginbuddy
	cp target/classes/net/loginbuddy/config/loginbuddy/CustomLoginbuddyConfigLoader.class docker-test/service/test-classes/net/loginbuddy/config/loginbuddy/CustomLoginbuddyConfigLoader.class
	cp docker-test/service/testCustomLoginbuddyConfig.json.bak docker-test/service/testCustomLoginbuddyConfig.json

build_all:
	mvn clean install
	docker build --no-cache --tag local/loginbuddy-test:latest .