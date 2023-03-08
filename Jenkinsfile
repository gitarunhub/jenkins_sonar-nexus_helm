pipeline {
    agent any
    environment {
        VERSION = "${env.BUILD_ID}"
    }

    stages{
        stage('sonar_quality_check'){
            agent {
                docker {
                    image 'maven'
                }
            }
            steps{
                script {
                    withSonarQubeEnv(credentialsId: 'sonar_server') {
                        sh 'mvn clean package sonar:sonar'
                    }
                }
            }
        }
        stage(quality_gate_wait){
            steps{
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar_server'
                }
            }
        }
        stage('mvn build'){
            steps{
                script{
                    sh 'mvn clean install'
                }
            }
        }
        stage('docker_image'){
            steps{
                script {
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus')]){
                        sh '''
                         sudo docker build -t 192.168.1.24:8085/springboot:${VERSION} .
                         docker login -u admin -p ${nexus} 192.168.1.24:8085
                         docker push 192.168.1.24:8085/springboot:${VERSION}
                         docker rmi 192.168.1.24:8085/springboot:${VERSION}
                         '''

                    }        
                }
            }
        }
        stage(nexu_helm_upload){
            steps{
                script{
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus')]){
                        dir('./kubernetes') {
                            sh '''
                            helmversion = $(helm show chart myapp | grep version | cut -d: -f 2 | tr -d ' ')
                            curl -u admin:${nexus_pass} http://192.168.1.24:8081/repository/helm-repo/ --upload-file myapp-${helmversion}.tgz -v
                            '''

                        }
                    }

                }
            }
        }
    }
}