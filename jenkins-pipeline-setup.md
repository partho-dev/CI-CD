## Why the Jenkins in Ec2 are slow sometimes

**Fix this through the UI**
- <img width="765" alt="Jenkins-slow" src="https://github.com/user-attachments/assets/ca42e39c-d5dd-4352-8d66-4814e2c21441">

**Fix the Slow issue through command**
- cd /var/lib/jenkins/
- update the new IP on this file - `jenkins.model.JenkinsLocationConfiguration.xml`


## Important security tools that can be considered in the pipeline

- SonarQube (SAST)
- OWASP ZAP (DAST)
- Checkmarx (SAST)
- Aqua Security (Container Security)
- Trivy (Container Security)


### Sonarqube for Static code analysis (Configure jenkins with sonar)
1. SonarQube (SAST)
- **Installation and Configuration**
- Run SonarQube as a Docker container or install it on a server. `docker run -d --name sonarqube -p 9000:9000 sonarqube`
- Or, make it as a container on EKS DevOps tool cluster
- Configure SonarQube:

- Access SonarQube UI at `http://localhost/sub_domain.domain.com:9000` and set up  project.
- Generate a token from SonarQube for Jenkins [Admission – Security – Users – Generate a Token]

- **Install SonarQube Scanner Plugin in Jenkins**:
- Go to Jenkins Dashboard > Manage Jenkins > Manage Plugins.
- Install the `SonarQube Scanner` plugin.

- **Configure SonarQube in Jenkins**:
- Go to Jenkins Dashboard > Manage Jenkins > Configure System.
- Add SonarQube server details under SonarQube Servers.
- Add SonarQube token in Jenkins Credentials.

- ![Jenkins-sonarqube-config](https://github.com/user-attachments/assets/c69454bd-8f24-4782-81ed-47089e0d524f)

```
environment {
        SONAR_HOST_URL = 'http://13.233.186.12:9000'
        }

            stage('SonarQube Analysis') {
                environment {
                scannerHome = tool 'sonarScanner'
                }
            steps {
                echo "<=======Initiating the SAST===========>"
                dir('nextJs-Sample') {
                    // Create sonar-project.properties inside 'nextJs-Sample' folder
                    writeFile file: 'sonar-project.properties', text: '''
                        sonar.projectKey=nextjs-sample-key-${env.BUILD_ID}
                        sonar.projectName=NextJs Sample Project
                        sonar.sources=.
                        sonar.language=js
                        sonar.sourceEncoding=UTF-8
                    '''
                    withSonarQubeEnv('sonarServer') {
                        // sh 'sonar-scanner'
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

```

### OWASP for Dynamic application security Testing (DAST)

- **Install OWASP ZAP:**
- Run OWASP ZAP as a Docker container or install it on a server.
- `docker run -u zap -p 8080:8080 -i owasp/zap2docker-stable zap.sh -daemon -port 8080`

- **Configure OWASP for Jenkins**
- Use the OWASP ZAP Plugin for Jenkins.
- Go to Jenkins Dashboard > Manage Jenkins > Manage Plugins.
- Install the `OWASP ZAP` plugin.
- Jenkins stage ex:
```
        stage('DAST with OWASP ZAP') {
            steps {
                script {
                    def zapHome = tool 'ZAP'
                    sh "${zapHome}/zap.sh -cmd -quickurl http://localhost:8080 -quickout zap_report.html"
                }
            }
        }
```


### Jenkins configuration with Nexus

**On the Nexus Server**
1. For http based nexus repo

- create a user with role as upload image & autheticate the nexus
- <img width="1024" alt="jenkins-users-nexus" src="https://github.com/user-attachments/assets/d4ac312c-5a4d-407d-a83f-158fc6cb00b7">

- Create Hosted Repo for Docker on Nexus (Hosted repo)
- <img width="943" alt="set-hosted-repo" src="https://github.com/user-attachments/assets/55881c4f-0715-42ef-9a6b-de0e02c7485e">
- Remember the Port on which the repo is active, in our case its `8092`
- Make sure, its active on inbound SG on Nexus

- Update the realm 
- <img width="511" alt="realm" src="https://github.com/user-attachments/assets/c5c99f82-2036-45cd-98a2-0a794be9ba30">


**On the Jenkins**
- install these plugins
  - `Nexus Artifact Uploader` (To upload the build/docker image to private nexus repo)
  - `Pipeline Utility Steps`

- COnfigure the nexus cred on Jenkins Global 
- <img width="1472" alt="jenkins-global-cred-nexus" src="https://github.com/user-attachments/assets/9a110da8-3b0c-4474-ba11-e5519c9d3974">

- ssh to the Jenkins server - `ssh root@jenkins_ip`
- `sudo vi /etc/docker/daemon.json`
    ```
    {
    "insecure-registries" : ["http://Nexus-server-IP:8092"] // Change the port what is set on nexus for docker hosted repo
    }

- Now go to pipeline and update the environment and stage

## How to Automate the above using Jenkins

```
    environment {
        SONAR_HOST_URL = 'http://13.233.186.12:9000'
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "http://54.175.95.188:8081"
        // DOCKER_REPO = 'http://54.175.95.188:8081/repository/erg-docker-hosted-repo'
        DOCKER_REPO = 'http://54.175.95.188:8092'
        // DOCKER_CREDENTIALS_ID = 'nexus-docker-creds'
        NEXUS_CREDENTIAL_ID = "jenkins-user-on-nexus"
    }

            stage('Docker Push to Nexus') {
            steps {
                echo "<=======Pushing the Docker Image to Nexus ===========>"
                script {
                    docker.withRegistry("${DOCKER_REPO}", "${NEXUS_CREDENTIAL_ID}") {
                        def app = docker.image("nextjs-sample:${env.BUILD_ID}")
                        app.push("latest")
                        app.push("${env.BUILD_ID}")
                    }
                }
            }
        }

```

- ![image](https://github.com/user-attachments/assets/db0b8ea5-3218-4524-b796-fa649a1e8190)



### Lets see how the Docker image looks on the Nexus
- In the pipeline, we are pushinh the image as `def app = docker.image("nextjs-sample:${env.BUILD_ID}")`
- So, on the nexus - we should look for the image on this directory - `nextjs-sample`

- <img width="1661" alt="Nexus-docker-img" src="https://github.com/user-attachments/assets/04a5b873-4d33-4b91-9381-4d672e19f8ea">

