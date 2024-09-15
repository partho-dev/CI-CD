
## Create a Private Nexus Repo for Docker images
- Go to Nexus, click Create Repo
- Select `Docker Hosted`
- <img width="893" alt="Nexus-Docker-Registry" src="https://github.com/user-attachments/assets/44ec7a86-35e1-4340-894e-813ac0feff79">

- <img width="766" alt="Nexus-Docker-Reg-Name" src="https://github.com/user-attachments/assets/c17382d1-c87f-4c84-833d-7605e6df2453">

- Update the Realm as active `Docker Bearer Token Realm`
- This is necessary for authentication when using Docker with Nexus.
- <img width="1093" alt="Realm" src="https://github.com/user-attachments/assets/778747f2-dda0-4d33-8484-5dc291573c97">

### To test the repository, we will mimic the stages of Jenkins

- 1. Install Docker to a Ubuntu server 

- 2. Install git on the server

- 3. Update the Docker Deamon to connect with the Nexus through insecure path

    - This is often necessary when using HTTP instead of HTTPS.

    - For production environments, it's recommended to secure the Nexus instance with HTTPS to avoid using insecure registries.
  
    - `sudo vi /etc/docker/daemon.json`
    ```
    {
    "insecure-registries" : ["http://3.16.26.143:8091"] 
    // "insecure-registries" : ["Nexus_URL:Port_mentioned_for_Docker_Repo"] 
    }
    ```
    - Restart the Docker Daemon - `systemctl restart docker`

    - verify the connectivity of client(Jenkins/Docker) & the Nexus - `sudo docker login -u admin 3.16.26.143:8091` 
    **Note** make sure the admin user has access to authenticat into the nexus

    - Enter the password set for the Nexus

    - Note : Make sure to log out of Docker if the login test with the credentials are done to avoid potential security issues. `sudo docker logout 3.16.26.143:8091`

- 4. Clone a github repo (Checkout stage) 
    - `sudo git clone https://github.com/partho-dev/sample-code.git`

- 5. Build the image (build stage)
    - `sudo docker build -t 3.16.26.143:8091/express .`

    - `sudo docker build -t 3.16.26.143:8091/express:1.0 .` # For Prod, its good to use version in auto increment

    - Verify if the image creation successful - `sudo docker images`

- 6. Push the image to Nexus Repo (Push the image to Repo)
    - `sudo docker push 3.16.26.143:8091/express`

- 7. Verify if the Image gets uploaded into the Nexus Docker Repo
    - <img width="842" alt="image-nexus" src="https://github.com/user-attachments/assets/2df4f20c-59ea-419f-a0ba-fdab4cba817a">



`========================================================`

### Setup Jenkins with Nexus

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



