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
                            helmversion=$(helm show chart myapp | grep version | cut -d: -f 2 | tr -d ' ')
                            tar -czvf myapp-${helmversion}.tgz myapp/
                            curl -u admin:${nexus} http://192.168.1.24:8081/repository/helm-repo/ --upload-file myapp-${helmversion}.tgz -v
                            '''

                        }
                    }

                }
            }
        }

        stage(transfer_helm_chart ) {
            steps{
                script{
                    withCredentials([sshUserPrivateKey(credentialsId: 'ssh_cluster', keyFileVariable: 'password', usernameVariable: 'kube')]) {
                        def remote = [:]
                        remote.name = 'test'
                        remote.host = '192.168.1.21'
                        remote.user = '${kube}'
                        remote.password = '${password}'
                        remote.allowAnyHosts = true
                        stage('Remote SSH') {
                            writeFile file: 'abc.sh', text: 'ls -lrt'
                            sshPut remote: remote, from: './kubernetes/myapp', into: '/home/kube/'
                            }
                    }


                }
            }
        }
        stage(deploy){
            steps{
                script {
                    sshagent(['Kube-ssh']) {
                        withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus')]){
                            dir('kubernetes/') {
                            sh '''     
                            ssh -o StrictHostKeyChecking=no kube@192.168.1.21 sudo docker login -u admin -p ${nexus} 192.168.1.24:8085
                            ssh -o StrictHostKeyChecking=no kube@192.168.1.21 sudo docker pull 192.168.1.24:8085/springboot:${VERSION}
                            ssh -o StrictHostKeyChecking=no kube@192.168.1.21 helm repo add helm-repo http://192.168.1.24:8081/repository/helm-repo/ --username admin --password ${nexus}
                             
                            ssh -o StrictHostKeyChecking=no kube@192.168.1.21 helm upgrade --install --set IMAGE_NAME=192.168.1.24:8085/springboot:${VERSION} --set IMAGE_TAG=${VERSION} springboot myapp/
                            '''
                            }                      
                        }                      
                    }
                }
                
            }
        }
    }
}