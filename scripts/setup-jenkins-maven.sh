#!/bin/bash
# This script sets up Maven settings in the Jenkins container

JENKINS_CONTAINER=$(docker ps -f name=jenkins -q)

if [ -z "$JENKINS_CONTAINER" ]; then
  echo "Jenkins container is not running. Please start Jenkins first."
  exit 1
fi

# Create .m2 directory if it doesn't exist
echo "Creating .m2 directory in Jenkins container..."
docker exec -u root $JENKINS_CONTAINER mkdir -p /var/jenkins_home/.m2

# Copy Maven settings file
echo "Copying Maven settings file..."
docker cp jenkins/settings.xml ${JENKINS_CONTAINER}:/var/jenkins_home/.m2/settings.xml

# Set proper permissions
echo "Setting permissions..."
docker exec -u root $JENKINS_CONTAINER chown -R jenkins:jenkins /var/jenkins_home/.m2

echo "Maven setup completed successfully!"
