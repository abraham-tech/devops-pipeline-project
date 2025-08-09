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
        
        // Artifactory configuration
        ARTIFACTORY_URL = 'http://10.0.0.98:8082/artifactory'
        MAVEN_OPTS = '-Dmaven.repo.local=.m2/repository -Dmaven.test.failure.ignore=true'
        
        // Repository configurations
        RESOLUTION_REPO = 'iwayq-libs-release'
        DEPLOY_REPO = 'iwayq-libs-release-local'
    }
    
    // This ensures the settings.xml is available before the build starts
    options {
        skipDefaultCheckout()
    }
    
    stages {
        // Stage 1: Checkout and Setup
        stage('Checkout and Setup') {
            steps {
                // Checkout the code
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
                
                // Ensure the .m2 directory exists
                sh 'mkdir -p ~/.m2'
                
                // Copy the settings.xml to the correct location
                dir('java-source') {
                    sh 'cp settings.xml ~/.m2/settings.xml'
                }
            }
        }
        
        // Stage 2: Build with Artifactory
        stage('Build') {
            steps {
                dir('java-source') {
                    // Build with Maven using Artifactory
                    sh """
                        mvn clean package \
                            -Dartifactory.publish.artifacts=true \
                            -Dartifactory.publish.buildInfo=true \
                            -Dartifactory.repository.prefix=${env.RESOLUTION_REPO} \
                            -Dartifactory.publish.artifacts.retries=3
                        
                        # Archive the built artifact
                        archiveArtifacts 'target/*.war'
                        
                        # Publish test results
                        junit '**/target/surefire-reports/**/*.xml'
                    """
                }
            }
        }
        
        // Stage 3: Publish to Artifactory
        stage('Publish to Artifactory') {
            steps {
                dir('java-source') {
                    script {
                        def buildInfo = '''
                        {
                            "name": "' + env.APP_NAME + '",
                            "number": "' + env.BUILD_NUMBER + '",
                            "buildAgent": {
                                "name": "Jenkins",
                                "version": "' + tool('maven') + '"
                            },
                            "modules": [
                                {
                                    "id": "' + env.APP_NAME + ':' + env.VERSION + '",
                                    "artifacts": [
                                        {
                                            "type": "war",
                                            "md5": "' + sh(script: 'md5sum target/*.war | cut -d\' \' -f1', returnStdout: true).trim() + '",
                                            "sha1": "' + sh(script: 'sha1sum target/*.war | cut -d\' \' -f1', returnStdout: true).trim() + '",
                                            "name": "' + env.APP_NAME + '-' + env.VERSION + '.war"
                                        }
                                    ]
                                }
                            ]
                        }
                        '''
                        
                        // Publish build info to Artifactory
                        sh """
                            curl -u admin:Admin123 -X PUT \
                                "${env.ARTIFACTORY_URL}/api/build" \
                                -H "Content-Type: application/json" \
                                -d '${buildInfo}'
                            
                            # Upload the artifact
                            curl -u admin:Admin123 \
                                -X PUT \
                                "${env.ARTIFACTORY_URL}/${env.DEPLOY_REPO}/com/iwayq/${env.APP_NAME}/${env.VERSION}/${env.APP_NAME}-${env.VERSION}.war" \
                                -T target/*.war
                        """
                    }
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
