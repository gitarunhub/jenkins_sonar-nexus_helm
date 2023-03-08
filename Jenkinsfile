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
                    withCredentials([string(credentialsId: 'sonar-server', variable: 'sonarqube')]) {
                        sh 'mvn clean package sonar:sonar'
                    }
                }
            }
        }
    }
}