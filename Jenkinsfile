pipeline {
    agent any

    environment {
        prod_ip_server = "192.168.137.128"
        registry = "oak92/divideexpenses"
		DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred-jakkarin_2')
	}

    stages {
        stage("Build oak92/divideexpenses image") {
            steps {
                script {
                    docker.build registry + ":latest"
                }
            }
        }

        stage("Login to Docker hub") {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage("Push image") {
            steps {
                sh 'docker push ${registry}:latest'
            }
        }

        stage("Deploy to production server") {
            steps {
                sshagent(["prod-credential_2"]) {
                    sh 'ssh -o StrictHostKeyChecking=no superuser@${prod_ip_server} docker-compose down'
                    sh 'ssh -o StrictHostKeyChecking=no superuser@${prod_ip_server} docker image rm ${registry}:latest'
                    sh 'scp -o StrictHostKeyChecking=no docker-compose.yml superuser@${prod_ip_server}:/home/superuser/'
                    sh 'ssh -o StrictHostKeyChecking=no superuser@${prod_ip_server} docker-compose up -d'

                }
            }
        }

        stage("Clean up") {
            steps {
                sh 'docker image rm ${registry}:latest'
            }
        }
    }


    post {
		always {
			sh 'docker logout'
		}
	}
}
