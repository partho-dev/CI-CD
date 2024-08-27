# CI-CD

# Continous Integration & Continuous Delivery or Deployment 

1. Jenkins would be used for CI/CD
2. For GitOps - Deployment of containers on K8S we will use Jenkins for only `CI` part and we will use K8S Custom Controller for `CD` part

* Jenkins need a seperate server to be installed, so we would use AWS `Ec2` to install Jenkins and other plugins which would perform differet stages in the `CI` 
* For Jenkins agent we will try to use Docker or the same server of Jenkins to perform some stages

## Important concepts to know before jumping into CI-CD
- Nexus | What is this & why it is needed?
- When we write applications using Java script, we may write in Typescript and so we need to build the code to be compiled into JS.
- But, when we run `npm run build` - It creates a `dist` folder in the root
- We take the content from that folder and place it on our web server under `/var/www/html`
- Here, once the code is pushed to `Github` - Jenkins pulls it - executes `npm run build`
- This creates the `dist` - Jenkins then pushes the `dist` into Nexus with some versions number attached

### What actually happens in the Jenkins in regards to Nexus 
1. Step 1: Build the Application
```
npm install
npm run build
```

2. Step 2: Archive the Artifacts
- Archive the dist folder using the Jenkins archive artifacts feature.
```
archiveArtifacts artifacts: 'dist/**'
```

3. Step 3: Upload Artifacts to Nexus
- Use a Nexus plugin or a script to upload the artifacts to Nexus.
```
nexusArtifactUploader artifacts: [[artifactId: 'my-react-app', file: 'dist', type: 'zip']], 
                      credentialsId: 'nexus-credentials', 
                      groupId: 'com.mycompany.app', 
                      nexusUrl: 'http://nexus.mycompany.com', 
                      protocol: 'http', 
                      repository: 'releases', 
                      version: '1.0.0'

```
- GitHub is a repository of the source code Similarly nexus is a repository of artifects like `dist`(Javascript based application like Angular) or `target folder`(Java bases application) `.Next`(for next application) 

## Sample Complete Pipeline Diagram for an application deployed to Kubernetes
- ![K8S-Deployment-CICD-Terraform](https://github.com/user-attachments/assets/f2a2d018-d200-48fb-9b1d-3614dd503063)

## Setting UP CI/CD

### Create Jenkins & Setup-configure

-	T2.large (both master & Client in one server)
-	Port 8080
-	Update the Ubuntu OS
-	Java (JDK 17 & above)
-	Install Jenkins
-	Install Docker
-	Add ubuntu user to docker group or execute this 
-	sudo chmod 666 /var/run/docker.sock
-	Configuration	
-	ip_address/8080
-	Install default plugins

-	Install custom plugins
    - Manage jenkins – plugins – available plugins
    - Pipeline Stage view (stage view is removed, so need this plugin)
    - SonarQube Scanner 
    - `Config file provider` (needed for Nexus to setup credentials)
    - Maven (Java based)
    - NodeJS
    - Pipeline maven integration (Java based)
    - Kubernetes | kubernetes credentials | kubernetes cli | lubernetes client api
    - Docker | Docker pipeline
    - NPM Plugin for Node.js-based projects.
    - Docker Pipeline Plugin for Docker image management.
    - Pipeline: AWS Steps (if you use AWS for deploying Docker images).
    - Nexus Artifact Uploader or Pipeline Nexus Publisher Plugin for publishing artifacts to Nexus.

-	Configure the installed plugins/Tools [ Remember these names that is being used to set these plaugin | These names would be used during the pipeline creation inside the `tools {}` block ]
    - Manage Jenkins – Tools
    - Docker – name(`docker`) – install automatically – add installer(download from docker.com)
    - Maven – name(`maven3`)
    - sonarQube
    - jdk - name (`jdk17`)
    - NodeJs - name(`node-18`)
    
### Create SonarQube & Setup-configure

-	Port 9000
-	T2.medium
-	Install docker - sudo apt install docker.io
-	Sudo docker run -d -p 9000:9000 sonarqube:lts-community
-	Ip_of_server:9000
-	Configure
-	Login – admin / admin 
-	Setup new pass
-	Create token which would be used on Jenkins 
    - Admission – Security – Users – Generate a Token

-	SonarQube has two elements
    - Sonar Qube server [ip_of_sonar_server:9000]
    - Sonar Qube Scanner [This happens on the source code which is checkout in Jekins server]
    - So, we need to connect Sonar server & Jenkins, for Jenkins to send the report to server

-	To Add the Sonar Token in Jenkins : In the Jenkins: Manage Jenkins - credentials – global – add credentials – secret Text – Add Sonar Token in “secret” field – Give any ID to remember that its for Sonar
-	To Add the Sonar Server IP in Jenkins : In the Jenkins: Manage Jenkins – systems – select SonarQube server(make sure the plugins are installed already) – name(sonar-server) – url(sonar_server_ip:9000) – Add the sonar token


### Create Nexus & Setup-configure 

-	Port 8081
-	T2.medium ( min 4GB RAM )

- Inside Docker
-	Install docker – sudo apt install docker.io
-	Install nexus as a Docker container
-	sudo docker run -d -p 8081:8081 sonartype/nexus3

- Without Docker, install directly on FS
- install Java first - `sudo apt install openjdk-17-jre-headless`
- create a `nexus` user - `sudo adduser --system --no-create-home --disabled-login --gecos "" nexus`
- download the installation files
```
cd /opt
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
sudo tar -zxvf latest-unix.tar.gz

```
- Change the user ownwrship of nexus
```
cd /opt
sudo mv nexus-3.* nexus
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/sonatype-work
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work
```
- Add the `nexus` user to run the nexus
```
sudo vim  /opt/nexus/bin/nexus.rc

Add the following line:
run_as_user="nexus" 
```
### Start the Nexus
- `sudo -u nexus /opt/nexus/bin/nexus start`

### Verify if its running
- Verify the nexus running - `ps aux | grep nexus`

-	**`Configuration`**
-	ip_address:8081
-	admin / [go inside docker container and find the pass ]
-	setup a new password

### How to build connection between Nexus & Jenkins for Java based applications

-   Build a connection between `Jenkins` & `Nexus`, which will help Jenkins to push the code package (`JAR`) artifacts into Nexus

-   **`Java based app`** : For adding the `Nexus URL`, go to Java source code and fine `pom.xml`
- at the end of POM.XML. add the `maven-release` &  `maven-snapshots` under `<distributionManagement>`

```
<distributionManagement>
    <repository>
        <id>...</id>   # maven-releases
        <url>...</url> # nexus_url:8081 -> Browse -> maven-releases -> Copy the URL 
    </repository>
    <snapshotRepository>
        <id>...</id>    # maven-snapshots
        <url>...</url>  # nexus_url:8081 -> Browse -> maven-snapshots -> Copy the URL 
    </snapshotRepository>
</distributionManagement> 
```
- The URL is added using pom.xml, now need to add the `credentials` of Nexus on Jenkins
- On the Jenkins, make sure this plugin is installed `Config file provider` - This would be used to setup Nexus credentials
- `Jenkins > Manage Jenkins > Managed Files` # Managed files is showing because the plugin `Config file provider` was installed 
- Click on Add New Config > Global Maven Setttings.xml > ID (`Maven-settings-for-nexus`) > Next > 
- This will give a settings.xml file and we need to update the Nexus creds under `<servers>` block
```
 <servers>
    <server>
      <id>maven-releases</id>
      <username>nexus_user_name</username>
      <password>nexus_password</password>
    </server>

     <server>
      <id>maven-snapshots</id>
      <username>nexus_user_name</username>
      <password>nexus_password</password>
    </server>
  </servers>

```


- Once the `Jenkins` & Nexus are configured, then write the Pipeline `stage`
```
stage('build_Java_Code') {
    steps {
        sh 'mvn package'
    }
}
    stage('Push_to_Nexus') {
    steps {
        withMaven(globalMavenSettingsConfig: 'Maven-settings-for-nexus', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true){
            sh 'mvn deploy'
        }
    }
}
```
- But, the above method of putting the credentials open in `settings.xml `is not safe, instead update the Jenkins Global credentials
- `Jenkins > manage Jenkins > Credentials > Global > Add credentials > secret text`
- & update the stage like this 

```
stage('Push_to_Nexus') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-credentials-id', usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD')]) {
            sh """
            mvn deploy \
            -Dusername=$NEXUS_USERNAME \
            -Dpassword=$NEXUS_PASSWORD
            """
        }
    }
}
```

4. Installl Trivi on Jenkins server (Jenkins does not have Trivy plugin)
-	Trivi is used to scan the file system for any code vulnerability
-	Install Trivi
-	Command to scan the filesystem and format the output 
-	`trivi fs --format table -o fs.html /server/src ` 
-	Trivy to scan the /server/src directory for vulnerabilities and generate an HTML report.

5. Create Pipleline on Jenkins
- Pipeline to Create EKS Cluster
    - Pipeline to deploy the application
- Each tool/plugins that needs to be configured in the Pipeline. It needs to be configured with tool block on the pipeline

- Tools block in Jenkins
```
pipeline {
    agent any
    
    tools {
        jdk 'jdk17 #its the name that we give while creating the tool on Pipeline'
        nodejs 'node-18 ' #this name should match the name of the Node.js tool configured in Jenkins.
    }

    stages {}
    }
```

### Lets have some comparison of Tools & Stages/steps for Java & Js
- This is Just an example to refer to
- `Java Script` Based application
- Lookat the Tools section & the stages section
```
pipeline {
    agent any

    tools {
        nodejs 'node-18' // Name of the configured Node.js tool
        npm 'npm-8.19.2' // Name of the configured npm tool
        yarn 'yarn-1.22.19' // Name of the configured Yarn tool
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh 'npm install' // Install dependencies using npm
            }
        }
        stage('Build') {
            steps {
                sh 'npm run build' // Build the JavaScript application
            }
        }
        stage('Test') {
            steps {
                sh 'npm run test' // Run unit tests using npm
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker build -t my-js-app .' // Build a Docker image
                sh 'docker push my-js-app' // Push the image to a registry
            }
        }
    }
}

```

- Java Based application
- Look at the Tools section & the stages section

```
pipeline {
    agent any

    tools {
        jdk 'jdk17' // Name of the configured JDK
        maven 'maven-3.8.6' // Name of the configured Maven tool
        gradle 'gradle-7.6' // Name of the configured Gradle tool
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package' // Build the Java application using Maven, This will create `target` folder which would be used by sonar to scan
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test' // Run unit tests using Maven
            }
        }
        stages {
        stage('sonar-scan') {
            steps {
                withSonarQubeEnv('sonar-server') #Its the sonar server that we set in Jenkins Tools, it has server URL & Token
                #put the scanner scrips here
                sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=todo -Dsonar.projectKey=todo \
                    -Dsonar.java.binaries=target '''
            }
        }
    }
        stage('Deploy') {
            steps {
                sh 'docker build -t my-java-app .' // Build a Docker image
                sh 'docker push my-java-app' // Push the image to a registry
            }
        }
    }
}
```
### What sonarQube does during the pipeline
- For Java based application
- tools {} is used to define the tools that will be available in the pipeline during execution.
- environment { ... }: This block defines environment variables that will be available in the pipeline during execution

```
pipeline {
    agent any
    
    tools {
        jdk 'jdk17 ' #its the name that we give while creating the tool on Pipeline
        nodejs 'node-18' #this name should match the name of the Node.js tool configured in Jenkins.
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }

    stages {
        stage('sonar-scan') {
            steps {
                withSonarQubeEnv('sonar-server') #Its the sonar server that we set in Jenkins Tools, it has server URL & Token
                #put the scanner scrips here
                sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=todo -Dsonar.projectKey=todo \
                    -Dsonar.java.binaries=target '''
            }
        }
    }
}

```

### Why sonar server is not inside the Tools block
- Defining SonarQube as a tool within the tools block might imply that it's a direct dependency of your build process.
- However, SonarQube is more of a service. By placing it in the environment block, it explicitly indicate that it's an external component that the pipeline interacts with.

- In the `steps{}` block 
- `-Dsonar.java.binaries=target` : here `target` folder gets created automatically while we run `mvn build` which compiles the Java files into the .class and all .class files are stored in `target` folder

- For `nextJS`  & `Express` or any `JS` based application, the codes are compiled using `npm run build`(check package.json)
- And they store the compiled code in `dist` or `.next` folder

- For `next` we will adjust the `step` - `-Dsonar.javascript.lcov.reportPaths=.next/coverage/lcov.info` [If the test is done with Jest and sonar scans that]
- commonly this is used `-Dsonar.nodejs.binary=node`

- For `Express` - `Dsonar.javascript.lcov.reportPaths`
- Express does not have any build 

## What nexus does during the Pipeline
- Nexus is not a plugin, its a seperate service which stores the artifacts (JAR, dist) etc after the code is packaged using `mvn package` or `npm run build`
- So, we have to first set its environment 
- Update the Nexus URL into Jenkins through POM.XML (file JAVA based application)
- Update the nexus creds into Global credentials on Jenkins
- On the Nexus server, ensure to allow multiple artifects on Nexus everytime the pipeline runs
    - `Enable deployment policy` for `maven-snapshots` under Repositories


## Create Docker image, tag and push
- Once the artifects are created and pushed to Nexus for versioning purpose,
- We can create the docker image from that artifacts on the local code under `/target` or `/dist` folder
- Before that, ensure the Dockerfile is updated to copy the files from /target folder

- Dockerfile
```
FROM eclipse-temurin:17-jdk-alpine
EXPOSE 8080
ENV APP_HOME /usr/src/app
COPY target/*.jar $APP_HOME/app.jar
WORKDIR $APP_HOME
CMD ["java", "-jar", "app.jar"]
```

- Jenkins pipeline for Docker image building/Tagging/Pushing to Dockerhub
```
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
    })}}
```

### Now its the time to deploy the image into K8s (EKS cluster)


### Why the sequence matters in pipeline
- If the `mvn compile` is not done before, it would not create `target` folder
- The sonar would not have anything to scan, because it looks for `target` folder

- #1 `Checkout` : Clones the repo on Jenkins server 
- #2 `compile` : `mvn compile` It compiles the JAVA code and stores all `.class` files inside `target` folder
- #3 `test` : `mvn test` Run the test on code (It can be jest or jmeter etc)
- #4 `scan filesystem` : `trivi fs --format table -o fs.html /server/src ` scans the filesystem
- #5 `sonar scan` : scans the compiled code vulnerability inside the `target folder`
- #6 `package Build` : `mvn package` Creates a JAR (Java Archive) file, which includes compiled `.class` files, resources, and dependencies and deployes to `Nexus`
- #7 `push to nexus` : 
- #8 `build docker image`
- #9 `push to docker repo` # Private docker hub or Nexus
- #10 