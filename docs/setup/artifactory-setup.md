# JFrog Artifactory Setup Guide

This document provides a comprehensive guide to installing and configuring JFrog Artifactory on an Ubuntu 24.04 server.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Post-Installation Configuration](#post-installation-configuration)
- [Service Management](#service-management)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)

## Prerequisites

- Ubuntu 24.04 LTS server
- Minimum 8GB RAM (16GB recommended for production)
- Minimum 20GB free disk space (SSD recommended)
- Java 11 or later (OpenJDK 17 recommended)
- sudo privileges

## Installation Steps

### 1. Update System Packages

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. Install Required Dependencies

```bash
sudo apt-get install -y wget curl gnupg2 software-properties-common
```

### 3. Add JFrog Repository

1. Add the JFrog GPG key:
   ```bash
   wget -qO - https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key | sudo apt-key add -
   ```

2. Add the JFrog repository:
   ```bash
   echo "deb https://releases.jfrog.io/artifactory/artifactory-debs $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/jfrog-artifactory.list
   ```

3. Update the package list:
   ```bash
   sudo apt-get update
   ```

### 4. Install JFrog Artifactory

```bash
sudo apt-get install -y jfrog-artifactory-oss
```

## Post-Installation Configuration

### 1. Start the Artifactory Service

```bash
sudo systemctl start artifactory.service
sudo systemctl enable artifactory.service  # Enable auto-start on boot
```

### 2. Verify Installation

Check the service status:
```bash
sudo systemctl status artifactory.service
```

Verify Artifactory is listening on port 8082:
```bash
sudo netstat -tuln | grep 8082
```

### 3. Access the Web Interface

Open a web browser and navigate to:
```
http://your-server-ip:8082
```

### 4. Initial Setup

1. Log in with the default credentials:
   - **Username:** admin
   - **Password:** password

2. Change the default admin password immediately after first login.
3. Configure your license (for non-OSS versions).
4. Set up your first repository.

## Service Management

### Start Artifactory
```bash
sudo systemctl start artifactory.service
```

### Stop Artifactory
```bash
sudo systemctl stop artifactory.service
```

### Restart Artifactory
```bash
sudo systemctl restart artifactory.service
```

### Check Status
```bash
sudo systemctl status artifactory.service
```

## Important Files and Directories

- **Installation Directory:** `/opt/jfrog/artifactory`
- **Configuration Directory:** `/opt/jfrog/artifactory/var/etc/`
- **Main Configuration File:** `/opt/jfrog/artifactory/var/etc/system.yaml`
- **Logs Directory:** `/opt/jfrog/artifactory/var/log/`
  - Main log file: `console.log`
  - Service logs: `artifactory-service.log`

## Database Configuration (Optional)

By default, Artifactory uses an embedded Derby database. For production use, it's recommended to set up an external PostgreSQL database.

### PostgreSQL Setup

1. Install PostgreSQL:
   ```bash
   sudo apt-get install -y postgresql postgresql-contrib
   ```

2. Create a database and user for Artifactory:
   ```bash
   sudo -u postgres psql -c "CREATE DATABASE artifactory;"
   sudo -u postgres psql -c "CREATE USER artifactory WITH PASSWORD 'your_secure_password';"
   sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE artifactory TO artifactory;"
   ```

3. Update the Artifactory configuration in `/opt/jfrog/artifactory/var/etc/system.yaml`:
   ```yaml
   shared:
     database:
       type: postgresql
       driver: org.postgresql.Driver
       url: jdbc:postgresql://localhost:5432/artifactory
       username: artifactory
       password: your_secure_password
   ```

4. Restart Artifactory:
   ```bash
   sudo systemctl restart artifactory.service
   ```

## Backup and Restore

### Backup Artifactory
```bash
sudo systemctl stop artifactory.service
sudo tar -czvf /backup/artifactory_backup_$(date +%Y%m%d).tar.gz /opt/jfrog/artifactory/var/
sudo systemctl start artifactory.service
```

### Restore Artifactory
```bash
sudo systemctl stop artifactory.service
sudo tar -xzvf /backup/artifactory_backup_YYYYMMDD.tar.gz -C /
sudo chown -R artifactory:artifactory /opt/jfrog/artifactory/var/
sudo systemctl start artifactory.service
```

## Security Considerations

1. **Change Default Credentials:** Always change the default admin password.
2. **Enable HTTPS:** Configure SSL/TLS for secure communication.
3. **Firewall Rules:** Configure your firewall to allow only necessary ports (default: 8081, 8082).
4. **Regular Backups:** Implement a regular backup strategy.
5. **Monitor Logs:** Regularly check the Artifactory logs for any suspicious activities.
6. **Keep Updated:** Regularly update Artifactory to the latest stable version.

## Troubleshooting

### Common Issues

1. **Port Conflicts:**
   - Check if port 8082 is already in use: `sudo lsof -i :8082`
   - Update the port in `/opt/jfrog/artifactory/var/etc/system.yaml`

2. **Permission Issues:**
   - Ensure the `artifactory` user has proper permissions:
     ```bash
     sudo chown -R artifactory:artifactory /opt/jfrog/artifactory/
     ```

3. **Service Not Starting:**
   - Check logs: `journalctl -u artifactory.service`
   - Verify Java installation: `java -version`

4. **Out of Memory Errors:**
   - Increase JVM heap size in `/opt/jfrog/artifactory/var/etc/system.yaml`:
     ```yaml
     shared:
       javaOpts:
         xms: 2g
         xmx: 4g
     ```

## Next Steps

1. Set up repository mirrors and remote repositories.
2. Configure user authentication (LDAP, SAML, OAuth, etc.).
3. Set up CI/CD integration.
4. Configure backup and retention policies.

## References

- [JFrog Artifactory Documentation](https://jfrog.com/help/r/jfrog-artifactory-documentation/artifactory-documentation)
- [JFrog System Requirements](https://jfrog.com/help/r/system-requirements)
- [JFrog Community Forums](https://jfrog.com/community/)
