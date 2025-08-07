# DevOps Pipeline Project

## Running Jenkins with Docker Compose

To start a self-contained Jenkins instance for this project:

```bash
docker-compose up -d
```

- Jenkins will be available at: http://localhost:8080
- The default Jenkins home is persisted in a Docker volume.

To stop Jenkins:

```bash
docker-compose down
```

Trigger 1
