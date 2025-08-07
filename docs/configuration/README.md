# Configuration Guide

This document provides detailed configuration options for the services in the DevOps pipeline.

## Jenkins Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JENKINS_OPTS` | `--httpPort=8080` | Jenkins server options |
| `JAVA_OPTS` | `-Djenkins.install.runSetupWizard=false` | Java options for Jenkins |

### Plugins

Required Jenkins plugins:
- Pipeline
- Docker Pipeline
- SonarQube Scanner
- Artifactory
- Kubernetes

## SonarQube Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SONAR_JDBC_URL` | `jdbc:postgresql://db:5432/sonar` | Database connection URL |
| `SONAR_JDBC_USERNAME` | `sonar` | Database username |
| `SONAR_JDBC_PASSWORD` | `sonar` | Database password |

### Quality Gates

Default quality gates are configured in the SonarQube web interface.

## JFrog Artifactory Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ARTIFACTORY_MASTER_KEY` | `FFFFFFFFFFFFFFF` | Master key for encryption |
| `ARTIFACTORY_EXTRA_JAVA_OPTIONS` | `-Xms512m -Xmx4g` | JVM options |

### Repositories

Default repositories are created automatically:
- `docker-local` - For Docker images
- `libs-release-local` - For release artifacts
- `libs-snapshot-local` - For snapshot artifacts

## Network Configuration

All services are connected to a bridge network called `sonarnet` for internal communication.

## Persistent Storage

Volumes are configured for all services to persist data between container restarts:

- Jenkins: `/var/jenkins_home`
- SonarQube: `/opt/sonarqube/data`, `/opt/sonarqube/extensions`, `/opt/sonarqube/logs`
- Artifactory: `/var/opt/jfrog/artifactory`, `/var/opt/jfrog/artifactory-backup`, `/var/opt/jfrog/artifactory/logs`
- PostgreSQL: `/var/lib/postgresql/data`
