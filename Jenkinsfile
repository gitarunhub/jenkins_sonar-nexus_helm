pipeline {
    agent any
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
                    sh 'waitForQualityGate abortPipeline: false, credentialsId: 'sonar_server''
                }
            }
        }
    }
}