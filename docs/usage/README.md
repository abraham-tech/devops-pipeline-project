# Usage Guide

This guide explains how to use the DevOps pipeline for your projects.

## Pipeline Overview

The CI/CD pipeline includes the following stages:

1. **Source Code Checkout**
2. **Build**
3. **Unit Tests**
4. **Code Quality Analysis**
5. **Package**
6. **Publish Artifacts**
7. **Deploy to Staging**
8. **Integration Tests**
9. **Deploy to Production**

## Setting Up a New Project

1. **Create a Jenkins Pipeline**
   - Log in to Jenkins
   - Click "New Item"
   - Enter a name and select "Pipeline"
   - In the Pipeline section, select "Pipeline script from SCM"
   - Configure your repository and credentials
   - Set the script path to `Jenkinsfile`

2. **Configure SonarQube Analysis**
   - Add a `sonar-project.properties` file to your project
   - Example configuration:
     ```properties
     sonar.projectKey=my-project
     sonar.projectName=My Project
     sonar.sources=src
     sonar.tests=test
     sonar.sourceEncoding=UTF-8
     sonar.java.binaries=target/classes
     ```

3. **Configure Artifactory**
   - Log in to Artifactory
   - Create repositories for your project if needed
   - Configure your build tool (Maven/Gradle) to publish to Artifactory

## Running the Pipeline

1. **Manual Trigger**
   - Navigate to your pipeline in Jenkins
   - Click "Build Now"

2. **Automatic Trigger**
   - Configure webhooks in your SCM to trigger builds on push
   - In Jenkins, go to your pipeline configuration
   - Under "Build Triggers", select "GitHub hook trigger for GITScm polling"

## Monitoring and Troubleshooting

### Jenkins
- Access build logs in the Jenkins web interface
- Check console output for detailed build information
- Monitor build history and test results

### SonarQube
- View code quality reports at http://localhost:9000
- Check for code smells, bugs, and security vulnerabilities
- Monitor code coverage and technical debt

### Artifactory
- Browse artifacts at http://localhost:8081
- Check build info and dependencies
- Monitor storage usage and clean up old artifacts if needed

## Best Practices

1. **Branching Strategy**
   - Use feature branches for new features
   - Create pull requests for code reviews
   - Merge to main branch only after successful pipeline run

2. **Versioning**
   - Follow semantic versioning (MAJOR.MINOR.PATCH)
   - Use tags for releases
   - Automate version updates in your build process

3. **Security**
   - Store sensitive information in Jenkins credentials
   - Use least privilege principle for service accounts
   - Regularly update dependencies with known vulnerabilities
