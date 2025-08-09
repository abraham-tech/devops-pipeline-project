# CI/CD Pipeline Setup Guide

## Work Summary - August 6, 2025

### Completed Tasks:
1. **Jenkins Pipeline Simplification**
   - Created a streamlined Jenkinsfile with essential stages:
     - Checkout source code
     - Build application (Maven package)
     - Run unit tests
   - Removed complex deployment stages for initial setup
   - Added proper post-build notifications

2. **Maven Build Fixes**
   - Fixed malformed pom.xml by removing duplicate closing tags
   - Verified local Maven build works correctly
   - Committed and pushed changes to the main branch

3. **Documentation**
   - Created a minimal Jenkinsfile for reference
   - Updated CI/CD setup documentation

### Next Steps:
1. Test the simplified pipeline in Jenkins
2. Gradually add back deployment stages (Dev, Staging, Prod)
3. Configure integration with Artifactory for artifact storage
4. Set up automated testing in the pipeline
5. Configure deployment to development environment

### Notes for Tomorrow:
- Verify Jenkins job configuration for the new pipeline
- Check Maven settings in Jenkins for proper artifact resolution
- Review build logs for any environment-specific issues
- Consider adding automated testing stages back to the pipeline

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Phase 1: Jenkins Setup](#phase-1-jenkins-setup)
3. [Phase 2: Pipeline Configuration](#phase-2-pipeline-configuration)
4. [Phase 3: Build and Test](#phase-3-build-and-test)
5. [Phase 4: Code Quality](#phase-4-code-quality)
6. [Phase 5: Security Scanning](#phase-5-security-scanning)
7. [Phase 6: Docker Integration](#phase-6-docker-integration)
8. [Phase 7: Artifactory Integration](#phase-7-artifactory-integration)
9. [Phase 8: Deployment](#phase-8-deployment)
10. [Troubleshooting](#troubleshooting)

## Prerequisites

- Docker and Docker Compose installed
- Jenkins server accessible at http://localhost:8080
- SonarQube server accessible at http://localhost:9000
- JFrog Artifactory accessible at http://localhost:8082/artifactory
- Git repository with your Java application code

## Phase 1: Jenkins Setup

### Step 1.1: Install Required Plugins
1. Log in to Jenkins
2. Go to `Manage Jenkins` > `Manage Plugins`
3. Install the following plugins if not already installed:
   - Pipeline
   - Docker Pipeline
   - SonarQube Scanner
   - OWASP Dependency-Check
   - Artifactory
   - Blue Ocean (optional, for better UI)
   - Git
   - GitHub/GitLab/Bitbucket (depending on your VCS)

### Step 1.2: Configure Global Tools
1. Go to `Manage Jenkins` > `Global Tool Configuration`
2. Configure:
   - JDK 11 (name: `jdk11`)
   - Maven (name: `maven`)
   - Docker (if using a remote Docker daemon)
   - SonarQube Scanner (name: `sonar-scanner`)
   - OWASP Dependency-Check (name: `owasp-dependency-checker`)

### Step 1.3: Configure Credentials
1. Go to `Manage Jenkins` > `Manage Credentials`
2. Add credentials for:
   - Git repository
   - Docker registry
   - Artifactory
   - Any other services you'll integrate with

## Phase 2: Pipeline Configuration

### Step 2.1: Create a New Pipeline Job
1. Click `New Item`
2. Enter a name (e.g., `java-app-pipeline`)
3. Select `Pipeline`
4. Click `OK`

### Step 2.2: Configure Pipeline
1. Under `Pipeline` section:
   - Select `Pipeline script from SCM`
   - Choose your SCM (Git)
   - Enter repository URL
   - Add credentials if needed
   - Set branch specifier (e.g., `*/master`)
   - Script path: `Jenkinsfile`

## Phase 3: Build and Test

### Step 3.1: Verify Build Configuration
1. The pipeline includes a `Build & Test` stage that will:
   - Compile the code
   - Run unit tests
   - Archive test results
   - Package the application

### Step 3.2: Test the Build Stage
1. Commit and push the Jenkinsfile
2. Run the pipeline
3. Verify the build completes successfully
4. Check test results in the build output

## Phase 4: Code Quality

### Step 4.1: Configure SonarQube
1. In Jenkins, go to `Manage Jenkins` > `Configure System`
2. Find `SonarQube servers` section
3. Add SonarQube installation:
   - Name: `sonar`
   - Server URL: `http://sonarqube:9000`
   - Add authentication token

### Step 4.2: Test Code Quality Stage
1. The pipeline includes a `Code Quality` stage that will:
   - Run SonarQube analysis
   - Generate code quality reports
2. Run the pipeline and verify:
   - SonarQube analysis completes
   - Results are visible in SonarQube dashboard

## Phase 5: Security Scanning

### Step 5.1: Configure OWASP Dependency-Check
1. In Jenkins, go to `Manage Jenkins` > `Global Tool Configuration`
2. Add OWASP Dependency-Check tool
3. Configure the path to the installation

### Step 5.2: Test Security Scan Stage
1. The pipeline includes a `Security Scan` stage that will:
   - Run dependency vulnerability scanning
   - Generate HTML/XML reports
2. Run the pipeline and verify:
   - Security scan completes
   - Reports are available in the build artifacts

## Phase 6: Docker Integration

### Step 6.1: Create Dockerfile
Create a `Dockerfile` in your project root:

```dockerfile
FROM openjdk:11-jre-slim
WORKDIR /app
COPY java-source/target/*.war app.war
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.war"]
```

### Step 6.2: Configure Docker Credentials
1. In Jenkins, add Docker registry credentials
2. Update `DOCKER_REGISTRY` in Jenkinsfile

### Step 6.3: Test Docker Build Stage
1. The pipeline includes a `Docker Build` stage that will:
   - Build a Docker image
   - Tag it with the build number
   - Push to the registry
2. Run the pipeline and verify:
   - Docker image is built successfully
   - Image is pushed to the registry

## Phase 7: Artifactory Integration

### Step 7.1: Configure Artifactory in Jenkins
1. Go to `Manage Jenkins` > `Configure System`
2. Find `JFrog Platform` section
3. Add Artifactory server:
   - Server ID: `jfrog`
   - URL: `http://18.207.136.250:8082/artifactory`
   - Add credentials

### Step 7.2: Test Artifactory Integration
1. The pipeline includes a `Publish to Artifactory` stage that will:
   - Deploy build artifacts
   - Handle versioning
2. Run the pipeline and verify:
   - Artifacts are published to Artifactory
   - Versioning is correct

## Phase 8: Deployment

### Step 8.1: Configure Deployment Environments
1. Set up your deployment targets (Dev, Staging, Production)
2. Configure credentials and access

### Step 8.2: Test Deployment Stages
1. The pipeline includes deployment stages for:
   - Development (auto-deploy on `develop` branch)
   - Staging (manual trigger on `release/*` branches)
   - Production (manual approval on `master` branch)
2. Test each environment deployment

## Troubleshooting

### Common Issues
1. **Build Failures**
   - Check Maven settings
   - Verify network access to dependencies

2. **Docker Issues**
   - Ensure Docker daemon is running
   - Check Docker registry credentials

3. **Artifactory Issues**
   - Verify Artifactory is running
   - Check repository permissions

4. **SonarQube Issues**
   - Check SonarQube server status
   - Verify project configuration

### Logs and Debugging
- Check Jenkins console output
- Review container logs: `docker-compose logs -f [service]`
- Check application logs in the respective services

## Next Steps

1. Set up monitoring for the pipeline
2. Configure notifications (Slack, Email)
3. Implement advanced deployment strategies (Blue/Green, Canary)
4. Set up automated rollback procedures

---

*This guide is a living document. Update it as your CI/CD pipeline evolves.*
