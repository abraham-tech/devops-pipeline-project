# Setup Guide

Follow these steps to set up the DevOps pipeline project on your local machine.

## Prerequisites

- Docker and Docker Compose installed
- Git installed
- At least 8GB RAM (16GB recommended)
- At least 20GB free disk space

## Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd devops-pipeline-project
   ```

2. **Start the services**
   ```bash
   docker-compose up -d
   ```

3. **Initialize Jenkins**
   - Access Jenkins at http://localhost:8080
   - Get the initial admin password:
     ```bash
     docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
     ```
   - Follow the setup wizard to complete Jenkins configuration

4. **Initialize SonarQube**
   - Access SonarQube at http://localhost:9000
   - Login with admin/admin
   - Change the default password when prompted

5. **Initialize JFrog Artifactory**
   - Access Artifactory at http://localhost:8081
   - Login with admin/password
   - Change the default password when prompted

## Verifying the Setup

Check that all services are running:

```bash
docker-compose ps
```

You should see all services with a status of 'Up'.

## Next Steps

- [Configure Jenkins jobs](../configuration/jenkins.md)
- [Set up your first pipeline](../usage/pipeline-guide.md)
