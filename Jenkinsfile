pipeline {
    agent any

    stages {
        stage('1.build_Java_Code') {
            steps {
                sh 'mvn package'
            }
        }
            stage('2.Push_to_Nexus-through-settings.xml') {
            steps {
                withMaven(globalMavenSettingsConfig: 'Maven-settings-for-nexus', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true){
                    sh 'mvn deploy'
                }
            }
        }
            stage('2. pushin-nexus-through-global-creds') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-credentials-id', usernameVaraible: 'NEXUS_USERNAME', passwordVariable:'NEXUS PASSW')]){
                    sh '''
                        mvn deploy \
                        -Dusername = $NEXUS_USERNAME \
                        -Dpassword=$NEXUS_PASSWORD
                    '''
                }
            }
        }
            stage('3.Docker-build-and-tag') {
            steps {
                //ensure to create the docker hub creds on Jenkins and give ID (Docker-Credentials)
                script(
                    withDockerRegistry(credentialsId: 'Docker-Credentials', toolName: 'docker'){
                        sh 'docker build -t daspratha/todo: latest .'
                    }
                )
            }
        }
            stage('4. Scan-docker-image') {
            steps {
                sh 'trivy image --format table -o docker_image.html daspratha/todo: latest'
            }
        }

            stage('5. Docker_image-Push') {
            steps {
                script(
            withDockerRegistry(credentialsId: 'Docker-Credentials', toolName: 'docker'){
                sh 'docker push -t daspratha/todo: latest'
            }
        )
            }
        }

    }
}
