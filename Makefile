build_all:
	mvn clean install
	docker build --no-cache --tag saschazegerman/loginbuddy-test:latest .

initialize_dev:
	sh initialize-dev-environment.sh