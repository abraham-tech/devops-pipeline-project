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
        
        // Use Maven Central directly for simplicity
        MAVEN_OPTS = '-Dmaven.repo.local=.m2/repository -Dmaven.test.failure.ignore=true'
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
        
        // Stage 2: Build and Test
        stage('Build and Test') {
            steps {
                dir('java-source') {
                    // Simple Maven build with tests
                    sh 'mvn clean package'
                    
                    // Archive the built artifact
                    archiveArtifacts 'target/*.war'
                    
                    // Publish test results
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
