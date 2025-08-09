pipeline {
    agent any
    
    tools {
        maven 'maven'
        jdk 'jdk11'
    }
    
    environment {
        // Application configuration
        APP_NAME = 'iwayqapp'
        VERSION = '1.0.${BUILD_NUMBER}'
        
        // JFrog Artifactory configuration
        JFROG_CLI_OFFER_CONFIG = 'false'
        // These should be configured in Jenkins Credentials
        ARTIFACTORY_URL = 'http://localhost:8082/artifactory'
        ARTIFACTORY_USER = 'admin'
        ARTIFACTORY_PASSWORD = 'Passme@1234'  // In production, use Jenkins credentials
        
        // Repository configurations
        RESOLUTION_REPO = 'iwayq-libs-release'
        DEPLOY_REPO = 'iwayq-libs-release-local'
    }
    
    stages {
        // Stage 1: Checkout Source Code
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [[$class: 'CleanBeforeCheckout']],
                    userRemoteConfigs: [
                        [
                            url: 'https://github.com/abraham-tech/devops-pipeline-project.git',
                            credentialsId: 'github-credentials'
                        ]
                    ]
                ])
            }
        }
        
        // Stage 2: Configure JFrog and Build
        stage('JFrog Configure') {
            steps {
                // Install JFrog CLI if not already installed
                sh '''
                    if ! command -v jf &> /dev/null; then
                        curl -fL https://install-cli.jfrog.io | sh
                    fi
                    
                    # Configure JFrog CLI
                    jf config add artifactory \
                        --url=${ARTIFACTORY_URL} \
                        --user=${ARTIFACTORY_USER} \
                        --password=${ARTIFACTORY_PASSWORD} \
                        --interactive=false
                    
                    # Test the connection
                    jf rt ping
                '''
            }
        }
        
        // Stage 3: Build and Package with JFrog
        stage('Build') {
            steps {
                dir('java-source') {
                    // Build with JFrog Maven
                    sh '''
                        jf mvnc "mvn clean package -DskipTests=true" \
                            --repo-resolve-releases=${RESOLUTION_REPO} \
                            --repo-resolve-snapshots=${RESOLUTION_REPO} \
                            --repo-deploy-releases=${DEPLOY_REPO} \
                            --repo-deploy-snapshots=${DEPLOY_REPO}
                        
                        # Archive the built artifact
                        archiveArtifacts 'target/*.war'
                    '''
                }
            }
        }
        
        // Stage 4: Run Tests with JFrog
        stage('Test') {
            steps {
                dir('java-source') {
                    // Run tests with JFrog Maven
                    sh '''
                        jf mvnc "mvn test" \
                            --repo-resolve-releases=${RESOLUTION_REPO} \
                            --repo-resolve-snapshots=${RESOLUTION_REPO}
                        
                        # Publish test results
                        junit '**/target/surefire-reports/**/*.xml'
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed. Check the build status.'
        }
        success {
            echo 'Build successful!'
        }
        failure {
            echo 'Build failed. Check the logs for details.'
        }
    }
}
