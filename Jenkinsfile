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
    }
}