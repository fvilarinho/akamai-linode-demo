Getting Started
---------------
This is a demo project for education/training purposes of DevOps. All the services used below are in the Cloud to facilitate the understanding.
The architecture uses microservices and containerization.

[![Master pipeline](https://github.com/fvilarinho/demo/actions/workflows/master.yml/badge.svg)](https://github.com/fvilarinho/demo/actions/workflows/master.yml)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=fvilarinho_demo&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=fvilarinho_demo)

The pipeline uses [`GitHub Actions`](https://github.com/features/actions) that contains a pipeline with 7 main phases described below:

### Compile, Build and Test
All commands of this phase are defined in `build.sh` file. 
It checks if there are no compile/build errors.
The tools used are:
- [`Gradle`](https://www.gradle.org) - Tool to automate the build of the code.

### Code Analysis - White-box testing (SAST)
All commands of this phase are defined in `codeAnalysis.sh` file. 
It checks Bugs, Vulnerabilities, Hotspots, Code Smells, Duplications and Coverage of the code.
If these metrics don't comply with the defined Quality Gate, the pipeline won't continue.
The tools used are:
- [`Gradle`](https://www.gradle.org) - Tool to automate the SAST analysis of the code.
- [`Sonar`](https://sonardcloud.io) - Service that provides SAST analysis of the code.

Environments variables needed in this phase:
- `GITHUB_TOKEN`: API Key used by Sonar client to communicate with GitHub.
- `SONAR_TOKEN`: API Key used by Sonar client to store the generated analysis.
- `SONAR_ORGANIZATION`: Identifier of the Sonar account.
- `SONAR_PROJECT_KEY`: Identifier of the Sonar project.
- `SONAR_URL`: URL of the Sonar server.

### Libraries Analysis - White-box testing (SAST)
All commands of this phase are defined in `librariesAnalysis.sh` file. 
It checks for vulnerabilities in internal and external libraries used in the code.
The tools used are:
- [`Gradle`](https://www.gradle.org) - Tool to automate the SAST analysis of the libraries.
- [`Snyk`](https://snyk.io) - Service that provides SAST analysis of the libraries.

Environments variables needed in this phase:
- `SNYK_TOKEN`: API Key used by Snyk to store the generated analysis.

### Packaging
All commands of this phase are defined in `package.sh` file.
It encapsulates all binaries in a Docker image.
Once the code and libraries were checked, it's time build the package to be used in the next phases.
The tools/services used are:
- [`Docker Compose`](https://docs.docker.com/compose) - Tool to build the images.

Environments variables needed in this phase:
- `DOCKER_REGISTRY_URL`: URL of the repository of packages.
- `DOCKER_REGISTRY_ID`: Identifier of the packages in the repository.

### Package Analysis - White-box testing (SAST)
All commands of this phase are defined in `packageAnalysis.sh` file.
It checks for vulnerabilities in the generated package.
The tools/services used are:
- [`Gradle`](https://www.gradle.org) - Tool to automate the SAST analysis of the package.
- [`Snyk`](https://snyk.io) - Service that provides SAST analysis of the package.

Environments variables needed in this phase:
- `SNYK_TOKEN`: API Key used by Snyk to store the generated analysis.

### Publishing
All commands of this phase are defined in `publish.sh` file.
It publishes the package in the Docker registry (GitHub Packages).
The tools/services used are:
- [`Docker Compose`](https://docs.docker.com/compose) - Tool to push the images into the Docker registry.
- [`Github Packages`](https://github.com) - Docker registry where the images are stored.
- 

Environments variables needed in this phase:
- `DOCKER_REGISTRY_URL`: URL of the repository of packages.
- `DOCKER_REGISTRY_ID`: Identifier of the packages in the repository.
- `DOCKER_REGISTRY_USER`: Username of the repository of packages.
- `DOCKER_REGISTRY_PASSWORD`: Password of the repository of packages.

### Deploy
All commands of this phase are defined in `deploy.sh` file.
It deploys the package in a K3S (Kubernetes) cluster.
The tools/services used are:
- [`Terraform`](https://terraform.io) - Infrastructure as a Code platform. 
- [`kubectl`](https://kubernetes.io/docs/reference/kubectl/overview/) - Kubernetes Orchestration tool. 
- [`Portainer`](https://portainer.io) - Kubernetes Orchestration UI.
- [`Linode`](https://www.linode.com) - Cloud provider where the infrastructure will be provisioned.
- [`Datadog Agent`](https://www.datadoghq.com) - Monitoring agent.

Environments variables needed in this phase:
- `DOCKER_REGISTRY_URL`: URL of the repository of packages.
- `DOCKER_REGISTRY_ID`: Identifier of the packages in the repository.
- `LINODE_TOKEN`: Token used to authenticate in the Linode platform.
- `LINODE_SSH_KEY`: Public key used to be installed in the provisioned infrastructure.
- `K3S_TOKEN`: Token used by the Kubernetes cluster.
- `TERRAFORM_TOKEN`: Token used to authenticate in the Terraform platform.
- `DATADOG_AGENT_KEY`: API key used to authenticate in the monitoring platform.

Comments
--------
### If any phase got errors or violations, the pipeline will stop.
### All environments variables must also have a secret with the same name. 
### You can define the secret in the repository settings. 
### DON'T EXPOSE OR COMMIT ANY SECRET IN THE PROJECT.

Architecture
------------
The application uses:
- [`Java 11`](https://www.oracle.com/br/java/technologies/javase-jdk11-downloads.html) - Programming Language.
- [`Spring Boot 2.7.0`](https://spring.io) - Development Framework.
- [`Gradle 6.8.3`](https://www.gradle.org) - Automation build tool.
- [`Mockito 3`](https://site.mockito.org/) - Test framework.
- [`JUnit 5`](https://junit.org/junit5/) - Test framework.
- [`MariaDB`](https://mariadb.com/) - Database server.
- [`NGINX 1.18`](https://www.nginx.com/****) - Web server.
- [`Docker 20.10.14`](https://www.docker.com) - Containerization tool.
- [`K3S 1.21.7`](https://k3s.io/) - Containerization tool.

For further documentation please check the documentation of each tool/service.

How to install
--------------
1. Linux operating system.
2. You need an IDE such as [IntelliJ](https://www.jetbrains.com/pt-br/idea).
3. You need an account in the following services:
`GitHub, Sonarcloud, Snyk, Linode and Terraform Cloud`.
4. You need to set the environment variables described above in you system.
5. The API Keys for each service must be defined in the UI of each service. Please refer the service documentation.
6. Fork this project from GitHub.
7. Import the project in IDE.
8. Commit some changes in the code and follow the execution of the pipeline in GitHub.

How to run it locally
------------------
1. In the project directory, execute the scripts below:
`./build.sh; ./package.sh; docker-compose -f ./iac/docker-compose.yml up`
2. Open the URL `http://localhost` in your preferred browser after the boot.

How to run it in the cloud
--------------------------------
1. Run the `deploy.sh` script that will provision your infrastructure, the kubernetes cluster/orchestration and the application microservices.
2. Open the URL `http://<infrastructure-ip>:30080` in your preferred browser after the boot.

Other Resources
----------------
- [Official Gradle documentation](https://docs.gradle.org)
- [Spring Boot Gradle Plugin Reference Guide](https://docs.spring.io/spring-boot/docs/2.7.0/gradle-plugin/reference/html/)
- [Spring Web](https://docs.spring.io/spring-boot/docs/2.7.0/reference/htmlsingle/#boot-features-developing-web-applications)
- [Spring Data JPA](https://docs.spring.io/spring-boot/docs/2.7.0/reference/htmlsingle/#boot-features-jpa-and-spring-data)
- [Serving Web Content with Spring MVC](https://spring.io/guides/gs/serving-web-content/)
- [Accessing Data with JPA](https://spring.io/guides/gs/accessing-data-jpa/)

All opinions and standard described here are my own.

That's it! Now enjoy and have fun!

Contact
-------
- LinkedIn: https://www.linkedin.com/in/fvilarinho
- e-Mail: fvilarinho@gmail.com
