# Loginbuddy-Test

This project is for testing [Loginbuddy](https://github.com/SaschaZeGerman/loginbuddy).

## Pre-Requisites

### Tooling

All Loginbuddy projects (including this one) use these tools and technologies:

- Docker
- Make
- Maven
- Java11
- SOAPUI

Before you continue, please verify that those tools are available!

This project uses SOAPUI for testing APIs. I got stuck with SOAPUI for many years and, although the name may not indicate it, it is good at testing REST APIs, too.

SOAPUI (Open Source) can be downloaded [here](https://www.soapui.org/downloads/soapui.html).

### Dependencies

The project depends on sources of Loginbuddy and Loginbuddy-Samples. Please clone and build those projects:

**Loginbuddy**

- `git clone https://github.com/SaschaZeGerman/loginbuddy.git`
- `cd loginbuddy`
- `make build_all`  // please follow the README if you run into problems
- `cd ..`

**Loginbuddy-Samples**

- `git clone https://github.com/SaschaZeGerman/loginbuddy-samples.git`
- `cd loginbuddy-samples`
- `make build_all`  // please follow the README if you run into problems
- `cd ..`

If you now run `docker images | grep loginbuddy` in a terminal you should find these images:

- saschazegerman/loginbuddy
- saschazegerman/loginbuddy-oidcdr
- saschazegerman/loginbuddy-demoserver
- saschazegerman/loginbuddy-democlient
- saschazegerman/loginbuddy-base

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
  - {loginbuddy-test}/soapui/project/**loginbuddy-basic.xml**  //  appears as *A-Loginbuddy-Service* and runs basic tests
  - {loginbuddy-test}/soapui/project/**loginbuddy-configManagement.xml**  //  appears as *B-Loginbuddy-ConfigManagement* and tests the management APIs
  - {loginbuddy-test}/soapui/project/**loginbuddy-flows.xml**  //  appears as *C-Loginbuddy-Flows* and runs through a simulation of OpenID Connect flows
  - {loginbuddy-test}/soapui/project/**Loginbuddy-Sidecar.xml**  //  appears as *D-Loginbuddy-Sidecar* and runs through tests using the sidecar deployment

You are now ready to test Loginbuddy!

## Running tests

All tests setup may be started in the terminal using make:

- `make run-test`  // launches a docker setup to be tested against
  - In SOAPUI, double-click the project **A-Loginbuddy-Service** and select the TestSuite menu. Click the green arrow and all tests are executed
  - In SOAPUI, double-click the project **B-Loginbuddy-ConfigManagement** and select the TestSuite menu. Click the green arrow and all tests are executed
- `make stop-test`  // stops all containers of the docker setup

You may run the same tests but this time with hazelcast as the session / cache implementation:

- `make run-test-hazelcast`
  - run the same SOAPUI tests as above
- `make stop-test-hazelcast`

The next one simulates several authorization_code flows:

- `make run-test-flows`  // launches a setup that simulates several OpenID Connect flows
  - In SOAPUI, double-click the project **C-Loginbuddy-Flows** and select the TestSuite menu. Click the green arrow and all tests are executed
- `make stop-test-flows`

The last one tests flows using the sidecar deployment:

- `make run-test-sidecar`  // launches a setup that leverages the sidecar deployment
  - In SOAPUI, double-click the project **D-Loginbuddy-Sidecar** and select the TestSuite menu. Click the green arrow and all tests are executed
- `make stop-test-sidecar`

If, at any point, SOAPUI does not show a green success bar, something is off and needs fixing in Loginbuddy!

### Important notes

The differences to 'real life' setups are these:
- `loginbuddy-sidecar`: the compose file exposes all ports of this container. This is required to connect from outside the docker network (SOAPUI). Since loginbuddy-sidecar
  would usually be launched in conjunction with a container that leverages it, that container would be part of the same network and therefore could access it via port 444 without having to expose it!
- `loginbuddy-oidcdr`: when this container launches, it imports the SSL certificate of demoserver.loginbuddy.net. This is required because self-signed certificates are
  not accepted by default and tests would fail
- `demoserver.loginbuddy.net`: when creating its DN for the self-signed certificate, it also includes 'loginbuddy-demoserver' as SAN name. This helps with DNS naming issues
  that arise from SOAPUI being outside of the docker network and the other containers being part of it

## Additional info

All SOAPUI projects are using properties instead of hard coded values. These can be found here:

- `./soapui/properties/template.properties`

If you want to use your own properties, simply copy that file and load them into SOAPUI for each project as *Custom Attributes*.

This file: `./soapui/INFO.md` has some tips for working with SOAPUI. 

## Done

At this point you ran all tests. The next, manual test (if you wish to do it) is to launch the Loginbuddy-Samples setup only to *play around* and see if anything unexpected appears.

## Known issues

- The SOAPUI project *C-Loginbuddy-Flows* has many duplicated test steps. This requires some effort to keep them in sync. When I get to it, I will do some refactoring
- Not everything is automated, but running the test indicates a high chance that most features work as expected