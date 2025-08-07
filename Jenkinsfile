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
        
        // Stage 2: Build and Package
        stage('Build') {
            steps {
                dir('java-source') {
                    sh 'mvn clean package -DskipTests'
                    archiveArtifacts 'target/*.war'
                }
            }
        }
        
        // Stage 3: Unit Tests
        stage('Test') {
            steps {
                dir('java-source') {
                    sh 'mvn test'
                    junit '**/target/surefire-reports/**/*.xml'
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
