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
        
        // JFrog Artifactory Configuration
        ARTIFACTORY_SERVER_ID = 'artifactory'
        ARTIFACTORY_URL = 'http://10.0.0.98:8082/artifactory'
        
        // Repository configurations
        RESOLUTION_REPO = 'iwayq-libs-release'
        DEPLOY_REPO = 'iwayq-libs-release-local'
        
        // Maven configuration
        MAVEN_OPTS = '-Dmaven.repo.local=.m2/repository -Dmaven.test.failure.ignore=true -Dartifactory.publish.artifacts=false'
    }
    
    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }
    
    // This ensures the settings.xml is available before the build starts
    parameters {
        booleanParam(name: 'SKIP_TESTS', defaultValue: true, description: 'Skip running tests')
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
        
        // Stage 2: Build with Maven
        stage('Build') {
            steps {
                dir('java-source') {
                    script {
                        // Create Maven settings with Artifactory configuration
                        def settings = """
                        <settings>
                            <servers>
                                <server>
                                    <id>${ARTIFACTORY_SERVER_ID}</id>
                                    <username>admin</username>
                                    <password>Admin123</password>
                                </server>
                            </servers>
                            <mirrors>
                                <mirror>
                                    <id>artifactory</id>
                                    <name>Artifactory</name>
                                    <url>${ARTIFACTORY_URL}/${RESOLUTION_REPO}</url>
                                    <mirrorOf>central</mirrorOf>
                                </mirror>
                            </mirrors>
                        </settings>
                        """
                        
                        // Write settings to file
                        writeFile file: 'artifactory-settings.xml', text: settings
                        
                        // Build the project with Maven
                        def mvnCmd = "mvn clean package"
                        if (params.SKIP_TESTS) {
                            mvnCmd += " -DskipTests"
                        }
                        
                        sh """
                            ${mvnCmd} \
                                -s artifactory-settings.xml \
                                -Dartifactory.publish.artifacts=false \
                                -Dmaven.wagon.http.ssl.insecure=true \
                                -Dmaven.wagon.http.ssl.allowall=true
                        """
                    }
                    
                    // Archive the built artifact
                    archiveArtifacts 'target/*.war'
                    
                    // Publish test results
                    junit '**/target/surefire-reports/**/*.xml'
                }
            }
        }
        
        // Stage 3: Publish to Artifactory
        stage('Publish to Artifactory') {
            steps {
                dir('java-source') {
                    script {
                        try {
                            // Generate build info
                            def buildInfo = """
                            {
                                "name": "${env.APP_NAME}",
                                "number": "${env.BUILD_NUMBER}",
                                "started": "${new Date().format("yyyy-MM-dd'T'HH:mm:ss.SSSZ")}",
                                "url": "${env.BUILD_URL}",
                                "modules": [
                                    {
                                        "id": "${env.APP_NAME}:${env.VERSION}",
                                        "artifacts": [
                                            {
                                                "type": "war",
                                                "name": "${env.APP_NAME}-${env.VERSION}.war"
                                            }
                                        ]
                                    }
                                ]
                            }
                            """
                            
                            // Write build info to file
                            writeFile file: 'build-info.json', text: buildInfo
                            
                            // Upload artifact to Artifactory
                            sh """
                                # Upload the WAR file
                                curl -u admin:Admin123 \
                                    -X PUT \
                                    "${env.ARTIFACTORY_URL}/${env.DEPLOY_REPO}/com/iwayq/${env.APP_NAME}/${env.VERSION}/${env.APP_NAME}-${env.VERSION}.war" \
                                    -T target/*.war
                                
                                # Publish build info
                                curl -u admin:Admin123 \
                                    -X PUT \
                                    "${env.ARTIFACTORY_URL}/api/build" \
                                    -H "Content-Type: application/json" \
                                    -d @build-info.json
                            """
                            
                            echo "Successfully published ${env.APP_NAME}-${env.VERSION}.war to Artifactory"
                        } catch (Exception e) {
                            error "Failed to publish to Artifactory: ${e.message}"
                        }
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
