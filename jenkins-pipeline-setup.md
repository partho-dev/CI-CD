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


### Sonarqube for Static code analysis
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

