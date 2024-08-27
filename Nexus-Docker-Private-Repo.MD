
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


    - sudo vi /etc/docker/daemon.json
    ```
    {
    "insecure-registries" : ["http://3.16.26.143:8091"] 
    // "insecure-registries" : ["Nexus_URL:Port_mentioned_for_Docker_Repo"] 
    }
    ```
    - Restart the Docker Daemon - `systemctl restart docker`

    - verify the connectivity of client(Jenkins/Docker) & the Nexus - `sudo docker login -u admin 3.16.26.143:8091` 

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



## How to Automate the above using Jenkins

```
pipeline {
    
    agent any
    
    environment {
        imageName = "Give_Image_Name"
        registryCredentials = "admin"
        registry = "3.16.26.143:8091"
        dockerImage = ''
    }
    
    stages {
        stage('checkout') {
            steps {
                git url: 'https://github.com/partho-dev/sample-code.git', branch: 'main'                  }
        }
    
    // Docker images
    stage('Docker image') {
      steps{
        script {
          dockerImage = docker.build(imageName)
        }
      }
    }

    // Push the image from Jenkins to Nexus
    stage('Push to Nexus') {
     steps{  
         script {
            docker.withRegistry('http://' + registry, registryCredentials) {
            dockerImage.push('latest')
            //or 
            //dockerImage.push("${env.BUILD_NUMBER}")
          }
        }
      }
    }
    
    // Run the container - Stop the container if its running
    stage('stop previous containers') {
         steps {
            sh 'docker ps -f name=container_name -q | xargs --no-run-if-empty docker container stop'
            sh 'docker container ls -a -f name=container_name -q | xargs -r docker container rm'
         }
       }
      
    stage('Docker Run') {
       steps{
         script {
                sh 'docker run -d -p 3000:3000 --rm --name container_name ' + registry + '/' + imageName + ':latest'
            }
         }
      }    
    }
}


```



