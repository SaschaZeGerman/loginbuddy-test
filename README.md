# Loginbuddy-Test

This project is for testing [Loginbuddy](https://github.com/SaschaZeGerman/loginbuddy).

## Pre-Requisites

### Tooling

All Loginbuddy projects (including this one) use these tools and technologies:

- Docker
- Make
- Maven
- Java11

Before you continue, please verify that those tools are available!

This project uses SOAPUI for testing APIs. I got stuck with SOAPUI for many years and, although the name may not indicate it, it is good at testing REST APIs, too.

SOAPUI (Open Source) can be downloaded [here](https://www.soapui.org/downloads/soapui.html).

### Dependencies

The project depends on sources of Loginbuddy and Loginbuddy-Samples. Please clone and build them:

**Loginbuddy**

- `git clone https://github.com/SaschaZeGerman/loginbuddy.git`
- `cd loginbuddy`
- `make build_all`  // please follow the README if you run into problems

**Loginbuddy-Samples**

- `git clone https://github.com/SaschaZeGerman/loginbuddy-samples.git`
- `cd loginbuddy-samples`
- `make build_all`  // please follow the README if you run into problems

If you now run `docker images` in a terminal you should find these images:

- saschazegerman/loginbuddy
- saschazegerman/loginbuddy-sidecar
- saschazegerman/loginbuddy-oidcdr
- saschazegerman/loginbuddy-demoserver
- saschazegerman/loginbuddy-democlient

### Hosts for testing purposes

All Loginbuddy projects use local hostnames rather than *localhost* to simulate real scenarios better.

- Update the hosts file and add these entries (you may already have some of them configured)
    - *127.0.0.1 loginbuddy-sidecar loginbuddy-oidcdr local.loginbuddy.net democlient.loginbuddy.net demoserver.loginbuddy.net soapui.loginbuddy.net*

## Preparing tests

This project not only uses Loginbuddy docker images but it also builds one to add a helper service that generates JWT during test execution.

To get started follow these steps:

- `make build_all` // this will build test sources and creates the image **local/loginbuddy-test**

This project holds four different SOAPUI projects and each one has a different purpose. To continue, launch SOAPUI:

- Update these preferences: (this is required only once)
  - check *File - Preferences - HTTP Settings - Pre-Encoded Endpoints*
- Do a right-click on `Projects` in the left explorer window and load all four projects, one after another:
  - {loginbuddy-test}/soapui/project/**loginbuddy-basic.xml**  //  appears as *A-Loginbuddy-Service*
  - {loginbuddy-test}/soapui/project/**loginbuddy-configManagement.xml**  //  appears as *B-Loginbuddy-ConfigManagement*
  - {loginbuddy-test}/soapui/project/**loginbuddy-flows.xml**  //  appears as *A-Loginbuddy-Flows*
  - {loginbuddy-test}/soapui/project/**Loginbuddy-Sidecar.xml**  //  appears as *A-Loginbuddy-Sidecar*

You are now ready to test Loginbuddy!

## Running tests

...

Next to this file there are three directories:
- **apitest/docker:** this contains docker related content to stand-up the testing environments
- **apitest/scripts:** this was only used when adding support for *response_type=id_token*
- **apitest/soapui:** contains SOAPUI projects and properties files

### Docker

**Directory: ./apitest/docker**

This directory contains the 'default' test setup and tests most bits and pieces. The test scenario consists of these components:
- `loginbuddy-oidcdr`: testing dynamic registration
- `loginbuddy-demo`: simulating the backend
- `loginbuddy-sidecar`: testing the sidecar setup
- `loginbuddy-test`: provides helper services

In addition, this test setup uses a custom Loginbuddy config loader.

To run the first set of tests do the following (assuming the pre-requisites are satisfied):
- `make run-test`  // it copies test files and lauches the docker containers
- Launch SOAPUI and import the projects `./soapui/project/loginbuddy-basic.xml`, `.../loginbuddy-configManagement.xml`
- run the test by double-clicking the imported project, select 'TestSuites' and click the green 'run button'

You should only see green diagrams!

When this is done, run `make stop-test` to stop the test environment!

**TIP**: Run `make run-test-hazelcast`/ `make stop-test-hazelcast` to use the setup leveraging Hazelcast!

To run the second set of tests do the following (assuming the pre-requisites are satisfied):
- `make run-test-flows`  // it copies test files and lauches the docker containers
- Launch SOAPUI and import the projects `.../loginbuddy-flows.xml`
- run the test by double-clicking the imported project, select 'TestSuites' and click the green 'run button'

You should only see green diagrams!

When this is done, run `make stop-test-flows` to stop the test environment!

**Directory: ./apitest/docker/sidecar**

This directory stands-up a test environment specifically for the sidecar deployment of Loginbuddy. It is used slightly different than how it would be used in a
real life scenario but this is to create tests that 'look into' Loginbuddy more. The test scenario consists of these components:
- `loginbuddy-sidecar`: receives request from SOAPUI as its client
- `loginbuddy-oidcdr`: used to test dynamic registration when loginbuddy-sidecar leverages that feature
- `demoserver.loginbuddy.net`: simulates an OpenID provider

All containers are configured for remote debugging!

The differences to 'real life' setups are these:
- `loginbuddy-sidecar`: the compose file exposes all ports of this container. This is required to connect from outside the docker network (SOAPUI). Since loginbuddy-sidecar
  would usually be launched with a container that leverages it, that container would be part of the same network and therefore could access it via port 444 by default!
- `loginbuddy-oidcdr`: when this container launches it imports the SSL vertificate of demoserver.loginbuddy.net. This is required because self-signed certificates are
  not accepted by default and tests would fail. This modification is preferred than implementing 'http' instead of using 'https'!
- `demoserver.loginbuddy.net`: when creating its DN for the self-signed certificate, it also includes 'loginbuddy-demoserver' as SAN name. This helps with DNS naming issues
  that arise from SOAPUI being outside of the docker network and the other containers being part of it.

To run the tests do the following (assuming the pre-requisites are satisfied):
- `docker-compose up`
- Launch SOAPUI and import the project `./soapui/project/Loginbuddy-Sidecar.xml`
- run the test by double-clicking the imported project, select 'TestSuites' and click the green 'run button'

You should only see green diagrams!

When this is done, run `docker-compose down` to stop the test environment!

### Custom Configuration Loader

This testsuite is using a custom loader for loading clients and providers. The custom loader has been implemented in **src** directory.

The class implementing the loader is configured here:
- file: `./docker-test/loginbuddy.properties`
- property: `config.loginbuddy.loader.default`

## Configure SOAPUI

All SOAPUI projects are using properties instead of hard coded values. These can be found here:

```$ ./soapui/properties/template.properties```

If you want to use your own properties, simply copy that file and load them into SOAPUI for each project.

## Known issues

- The SOAPUI project *Loginbuddy-Flows* has many duplicated test steps. This requires some effort to keep them in sync. When I get to it, I will do some refactoring
- Not everything is automated, but running the test indicates a high chance that most features are working as expected
- Manual verifications are required via the browser UI