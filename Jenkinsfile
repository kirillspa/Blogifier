pipeline {
    agent any
    stages {
        stage('Docker Build') {
            steps {
                echo 'Start Docker build.'
                sh 'docker build -t localhost:8083/kirillspa/blogifier:latest .'
            }
        }
        stage('Push to Nexus') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    echo 'Push Blogifier image to Nexus artifact repository'
                    sh 'docker login localhost:8083 -u ${DOCKER_USER} -p ${DOCKER_PASS}'
				    sh 'docker push localhost:8083/kirillspa/blogifier:latest' 
                }
            }
        }
    }
}
