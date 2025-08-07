pipeline {
  agent any
  
  environment {
    // Application configuration
    APP_NAME = 'iwayqapp'
    VERSION = '1.0.${BUILD_NUMBER}'
    DOCKER_REGISTRY = 'your-docker-registry' // Update with your registry
    
    // Environment URLs
    DEV_URL = 'http://dev.example.com'
    STAGING_URL = 'http://staging.example.com'
    PROD_URL = 'http://prod.example.com'
    
    // SonarQube configuration
    SONAR_SCANNER_HOME = tool 'sonar-scanner'
  }
  
  tools {
    maven 'maven'
    jdk 'jdk11' // Ensure JDK 11 is configured in Jenkins
  }
  
  // Maven settings configuration
  environment {
    // Path to Maven settings file
    MAVEN_SETTINGS = '${WORKSPACE}/settings.xml'
    
    // Maven options
    MAVEN_OPTS = '-Xmx1024m -XX:MaxPermSize=256m'
    
    // Build configuration
    BUILD_OPTS = '-DskipTests=false -Dmaven.test.failure.ignore=false -Dmaven.test.reportsDirectory=${WORKSPACE}/test-reports'
  }
  
  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 1, unit: 'HOURS')
    disableConcurrentBuilds()
    ansiColor('xterm')
  }
  
  stages {
    // Stage 1: Checkout Source Code
    stage('Checkout SCM') {
      steps {
        script {
          checkout([
            $class: 'GitSCM',
            branches: [[name: '*/main']],
            extensions: [[$class: 'CleanBeforeCheckout']],
            userRemoteConfigs: [
              [
                credentialsId: 'git',
                url: 'https://iwayqtech@bitbucket.org/iwayqtech/devops-pipeline-project.git'
              ]
            ]
          ])
        }
      }
    }
    
    // Stage 2: Build and Unit Test
    stage('Build & Test') {
      steps {
        dir('java-source') {
          script {
            // Build the application and run unit tests
            withMaven(
              maven: 'maven',
              mavenSettingsConfig: 'artifactory-settings',
              mavenOpts: env.MAVEN_OPTS,
              jdk: 'jdk11'
            ) {
              // Clean and package the application
              sh "mvn clean package ${env.BUILD_OPTS} -s ${env.MAVEN_SETTINGS}"
              
              // Generate JaCoCo code coverage report
              sh "mvn jacoco:report -s ${env.MAVEN_SETTINGS}"
              
              // Archive test results
              junit '**/target/surefire-reports/**/*.xml'
              
              // Archive JaCoCo coverage report
              publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'target/site/jacoco',
                reportFiles: 'index.html',
                reportName: 'JaCoCo Report'
              ])
              
              // Archive the WAR file
              archiveArtifacts artifacts: 'target/*.war', fingerprint: true
              
              // Record test results
              recordIssues(
                tools: [java()],
                sourceCodeEncoding: 'UTF-8'
              )
            }
          }
        }
      }
      post {
        success {
          echo 'Build and unit tests completed successfully!'
        }
        failure {
          echo 'Build or unit tests failed!'
        }
      }
    }
    
    // Stage 3: Code Quality Analysis
    stage('Code Quality') {
      when {
        expression { env.BRANCH_NAME == 'master' || env.CHANGE_TARGET == 'master' }
      }
      steps {
        dir('java-source') {
          withSonarQubeEnv('sonar') {
            sh """
            mvn sonar:sonar \
              -Dsonar.projectKey=${APP_NAME} \
              -Dsonar.projectName=${APP_NAME} \
              -Dsonar.projectVersion=${VERSION} \
              -Dsonar.sources=src \
              -Dsonar.java.binaries=target/classes \
              -Dsonar.java.libraries=target/**/*.jar \
              -Dsonar.tests=src/test \
              -Dsonar.java.test.binaries=target/test-classes \
              -Dsonar.java.test.libraries=target/test-classes/**/*
            """
          }
        }
      }
    }
    
    // Stage 4: Security Scan
    stage('Security Scan') {
      when {
        expression { env.BRANCH_NAME == 'master' || env.CHANGE_TARGET == 'master' }
      }
      steps {
        dir('java-source') {
          // OWASP Dependency-Check for vulnerability scanning
          dependencyCheck additionalArguments: '''--scan ./ --format HTML --format XML 
            --out . --enableExperimental --failBuildOnCVSS 8
            --suppression ${WORKSPACE}/dependency-check-suppression.xml''', 
          odcInstallation: 'owasp-dependency-checker'
          
          // Publish dependency check results
          dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
          
          // Archive the full report
          archiveArtifacts '**/dependency-check-report.*'
        }
      }
    }
    
    // Stage 5: Build Docker Image
    stage('Docker Build') {
      when {
        expression { env.BRANCH_NAME == 'master' || env.CHANGE_TARGET == 'master' }
      }
      steps {
        script {
          // Build Docker image
          docker.withRegistry('https://' + DOCKER_REGISTRY, 'docker-credentials') {
            def customImage = docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}", '--build-arg VERSION=${VERSION} -f Dockerfile .')
            
            // Push the image to the registry
            customImage.push()
            
            // For development, also tag as 'latest'
            if (env.BRANCH_NAME == 'master') {
              customImage.push('latest')
            }
          }
        }
      }
    }
    
    // Stage 6: Publish to Artifactory
    stage('Publish to Artifactory') {
      when {
        expression { env.BRANCH_NAME == 'master' || env.CHANGE_TARGET == 'master' }
      }
      steps {
        script {
          // Configure Artifactory
          rtServer (
            id: "jfrog",
            url: "http://localhost:8082/artifactory",
            credentialsId: "artifactory-credentials"
          )
          
          // Configure Maven deployer
          rtMavenDeployer (
            id: "MAVEN_DEPLOYER",
            serverId: "jfrog",
            releaseRepo: "iwayq-libs-release-local",
            snapshotRepo: "iwayq-libs-snapshot-local"
          )
          
          // Deploy artifacts to Artifactory
          dir('java-source') {
            withMaven(
              maven: 'maven',
              mavenSettingsConfig: 'artifactory-settings',
              mavenOpts: env.MAVEN_OPTS,
              jdk: 'jdk11'
            ) {
              rtMavenRun(
                tool: 'maven',
                pom: 'pom.xml',
                goals: 'deploy',
                deployerId: 'MAVEN_DEPLOYER',
                version: VERSION,
                opts: '-Dmaven.test.skip=true'
              )
              
              // Publish build info to Artifactory
              rtPublishBuildInfo(
                serverId: "jfrog"
              )
            }
          }
        }
      }
    }
    
    // Stage 7: Deploy to Development
    stage('Deploy to Dev') {
      when {
        branch 'develop'  // Only run for develop branch
      }
      steps {
        script {
          // Deploy to development environment
          echo "Deploying version ${VERSION} to Development"
          // Add your deployment commands here, e.g., Ansible, kubectl, etc.
          
          // Example: Trigger deployment job
          // build job: 'deploy-dev', parameters: [
          //   string(name: 'VERSION', value: VERSION),
          //   string(name: 'ENVIRONMENT', value: 'dev')
          // ]
        }
      }
    }
    
    // Stage 8: Integration Tests
    stage('Integration Tests') {
      when {
        branch 'release/*'  // Only run for release branches
      }
      steps {
        dir('java-source') {
          // Run integration tests
          sh 'mvn verify -Pintegration-tests'
          
          // Archive integration test results
          junit '**/target/failsafe-reports/**/*.xml'
        }
      }
    }
    
    // Stage 9: Deploy to Staging
    stage('Deploy to Staging') {
      when {
        branch 'release/*'  // Only run for release branches
      }
      steps {
        script {
          // Deploy to staging environment
          echo "Deploying version ${VERSION} to Staging"
          // Add your deployment commands here
          
          // Example: Trigger deployment job
          // build job: 'deploy-staging', parameters: [
          //   string(name: 'VERSION', value: VERSION),
          //   string(name: 'ENVIRONMENT', value: 'staging')
          // ]
        }
      }
    }
    
    // Stage 10: Deploy to Production
    stage('Deploy to Production') {
      when {
        branch 'master'  // Only run for master branch
      }
      steps {
        script {
          // Manual approval for production deployment
          timeout(time: 1, unit: 'HOURS') {
            input message: "Deploy to production?", ok: 'Deploy'
          }
          
          // Deploy to production environment
          echo "Deploying version ${VERSION} to Production"
          // Add your deployment commands here
          
          // Example: Trigger deployment job
          // build job: 'deploy-prod', parameters: [
          //   string(name: 'VERSION', value: VERSION),
          //   string(name: 'ENVIRONMENT', value: 'prod')
          // ]
          
          // Send deployment notification
          // emailext (
          //   subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
          //   body: "Deployed ${APP_NAME} ${VERSION} to production.\n${env.BUILD_URL}",
          //   to: 'devops@example.com',
          //   recipientProviders: [[$class: 'DevelopersRecipientProvider']]
          // )
        }
      }
    }
                )

                script {
                    rtMavenResolver (
                        id: "MAVEN_RESOLVER",
                        serverId: "jfrog",
                        releaseRepo: "iwayq-libs-release",
                        snapshotRepo: "iwayq-libs-snapshot"
                    )
                }
            }
    }

    stage ('Deploy Artifacts') {
            steps {
                rtMavenRun (
                    tool: "maven", // Tool name from Jenkins configuration
                    pom: 'java-source/pom.xml',
                    goals: 'clean install',
                    deployerId: "MAVEN_DEPLOYER",
                    resolverId: "MAVEN_RESOLVER"
                )
         }
    }

    stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "jfrog"
             )
        }
    }

    stage('Copy Dockerfile & Playbook to Ansible Server') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "scp -o StrictHostKeyChecking=no Dockerfile ec2-user@3.91.67.214:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no create-container-image.yaml ec2-user@3.91.67.214:/home/ec2-user"
                    }
                }
            
        } 
    stage('Build Container Image') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.91.67.214 -C \"sudo ansible-playbook create-container-image.yaml\""
                        
                    }
                }
            
        } 
    stage('Copy Deployent & Service Defination to K8s Master') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "scp -o StrictHostKeyChecking=no create-k8s-deployment.yaml ec2-user@3.237.42.29:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no nodePort.yaml ec2-user@3.237.42.29:/home/ec2-user"
                    }
                }
            
        } 

    stage('Waiting for Approvals') {
            
        steps{

				input('Test Completed ? Please provide  Approvals for Prod Release ?')
			  }
            
    }     
    stage('Deploy Artifacts to Production') {
            
            steps {
                  sshagent(['sshkey']) {
                       
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.237.42.29 -C \"sudo kubectl apply -f create-k8s-deployment.yaml\""
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.237.42.29 -C \"sudo kubectl apply -f nodePort.yaml\""
                        
                    }
                }
            
        } 
         
   } 
}
