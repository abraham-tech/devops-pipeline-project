# Running JFrog Artifactory

This document provides a comprehensive guide on how to run and manage the JFrog Artifactory service in your development environment.

## Prerequisites

- Docker and Docker Compose installed on your system
- At least 4GB of available RAM (8GB recommended)
- At least 10GB of free disk space

## Quick Start

1. Navigate to the project root directory:
   ```bash
   cd /path/to/devops-pipeline-project
   ```

2. Start the Artifactory service:
   ```bash
   docker compose -f docker-compose.artifactory.yml up -d
   ```

3. Access the Artifactory web interface:
   - URL: http://localhost:8082/artifactory/
   - Username: `admin`
   - Password: `password`

## Detailed Setup

### Starting the Service

To start Artifactory with its dependencies:

```bash
# Start all services in detached mode
docker compose -f docker-compose.artifactory.yml up -d

# Verify the service is running
docker compose -f docker-compose.artifactory.yml ps
```

### Stopping the Service

To stop the Artifactory service:

```bash
# Stop the containers
docker compose -f docker-compose.artifactory.yml stop

# To stop and remove containers, networks, and volumes
docker compose -f docker-compose.artifactory.yml down -v
```

### Accessing Logs

To view the Artifactory logs:

```bash
# Follow the logs in real-time
docker compose -f docker-compose.artifactory.yml logs -f

# View the last 100 lines of logs
docker compose -f docker-compose.artifactory.yml logs --tail=100
```

### Resetting Artifactory

To completely reset Artifactory (this will delete all data):

```bash
# Stop and remove all containers and volumes
docker compose -f docker-compose.artifactory.yml down -v

# Remove any dangling volumes
docker volume prune -f

# Start fresh
docker compose -f docker-compose.artifactory.yml up -d
```

## Configuration

### Environment Variables

The following environment variables can be configured in `docker-compose.artifactory.yml`:

- `ARTIFACTORY_HOME`: Home directory for Artifactory (default: `/var/opt/jfrog/artifactory`)
- `ARTIFACTORY_USER_ID`: User ID to run Artifactory as (default: `1030`)
- `ARTIFACTORY_GROUP_ID`: Group ID to run Artifactory as (default: `1030`)
- `ARTIFACTORY_MASTER_KEY`: Master key for encryption (auto-generated if not provided)

### Ports

- `8081`: HTTP access to Artifactory
- `8082`: HTTPS access to Artifactory
- `5001`: Docker registry port (HTTPS)
- `5002`: Docker registry port (HTTP)

## Troubleshooting

### Common Issues

1. **Port Conflicts**:
   - Ensure ports 8081, 8082, 5001, and 5002 are not in use by other services
   - Check for conflicts with: `sudo lsof -i :<port>`

2. **Permission Issues**:
   - If you encounter permission errors, ensure the Docker daemon has proper permissions
   - Try running with `sudo` if necessary

3. **Container Fails to Start**:
   - Check logs: `docker compose -f docker-compose.artifactory.yml logs`
   - Ensure you have enough disk space: `df -h`
   - Verify Docker has enough memory: `docker info | grep -i memory`

### Checking Service Health

To check if Artifactory is running properly:

```bash
# Check container status
docker compose -f docker-compose.artifactory.yml ps

# Check Artifactory health endpoint
curl -u admin:password http://localhost:8082/artifactory/api/system/ping
```

## Backup and Restore

### Creating a Backup

```bash
# Create a backup of Artifactory data
docker exec -it artifactory /bin/bash -c "tar -czvf /var/opt/jfrog/artifactory/backup/artifactory-backup-$(date +%Y%m%d).tar.gz /var/opt/jfrog/artifactory/data"
```

### Restoring from Backup

```bash
# Copy backup file to container
docker cp backup-file.tar artifactory:/tmp/backup.tar

# Restore from inside the container
docker exec -it artifactory /bin/bash -c "cd / && tar -xzvf /tmp/backup.tar"

# Restart the container
docker compose -f docker-compose.artifactory.yml restart artifactory
```

## Maintenance

### Upgrading Artifactory

1. Pull the latest image:
   ```bash
   docker pull releases-docker.jfrog.io/jfrog/artifactory-jcr:latest
   ```

2. Stop and remove the old container:
   ```bash
   docker compose -f docker-compose.artifactory.yml down
   ```

3. Start with the new version:
   ```bash
   docker compose -f docker-compose.artifactory.yml up -d
   ```

### Monitoring

To monitor Artifactory's resource usage:

```bash
# View container resource usage
docker stats artifactory

# View disk usage
docker exec -it artifactory df -h /var/opt/jfrog/artifactory
```

## Security Considerations

1. **Change Default Credentials**:
   - Change the default admin password after first login
   - Create separate users with appropriate permissions

2. **Enable HTTPS**:
   - Configure SSL/TLS for production use
   - Use Let's Encrypt or your organization's certificates

3. **Regular Backups**:
   - Schedule regular backups of your Artifactory data
   - Test restore procedures periodically

## Support

For additional help, refer to:
- [JFrog Artifactory Documentation](https://www.jfrog.com/confluence/display/JFROG/Getting+Started)
- [Docker Documentation](https://docs.docker.com/)
- [Project README](../README.md)
