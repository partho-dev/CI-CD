## What is an Artifacts
- Artifacts are the output of any software build process, for example `.exe` file is an artifacts
- When we create a docker image using docker build command, it creates a docker image as an output and this is an artifacts
- Basically an Artifacts can be anything, including Docker images, text files, or Helm charts. 
- There are other examples as well, for JAVA based software the artifacts are WAR files, reports, log files, zip, tar etc
- So, to store all these artifacts we need a repository and one of those repositories is `Nexus`
- `Nexus` is one of the products of a company called `sonatype`

### Why do we need a repository, we can directly push the artifacts to our deployment server
- Ok, so, we need to understand, deployment is a different process and that comes under `CD`
- & the Creating the artifacts is coming under `CI`
- During CI, the pipeline creates the artifacts and stores in some remote repo like Nexus 
- & during the CD process, the artifacts gets pulled from repo and get applied into the Deployment
- Everytime we push the artifacts into Nexus, it gets versioned and its easier to rollback to older version, rather rebuilding a new artifacts using old source commitments.
- If we use any public repositories like `Dockerhub`, `npm`, `apt-get`, `yum` we dont have any control on the access, but the `Private` repo like `Nexus` has granular control on user level and on policy level as well
-  So, we have to configure the Nexus to be a single point of truth for all the repositories an organisation needs to protect their IP.
- To have controll on the Private repository like Nexus, we need something called `Repository Manager` which ensures
    - Configure users, provide RBAC to controll the access control 
    - It helps to store or retrieve any build artifacts
    - It helps to create different types of Repositories (`3 types` - `Proxy Repo`, `Hosted Repi`, `Group Repo` )
    - Repository Manager helps proxy any remote repositories & caches its content locally for further use by the internal orgs
    - Maintains a repo for its own internal artifacts

### What are the different types of Repositories Nexus has

- ![Nexus-Repo](https://github.com/user-attachments/assets/894a8326-56c7-4b26-8cba-7e62dba7163b)

- Nexus Repository Manager has three types of repositories: 
    - `Proxy repositories`: Acts as a cache for public repositories like Dockerhub for Docker images.
        - The public repo url `https://hub.docker.com/` should be whitelisted in the proxy server

    - `Hosted repositories`: Store buld artifacts on Nexus, accessible only to the user with SSO, or Ldap or users from orgs. Not from outside world.
        - Nexus repository manager provides `Maven` with two types of hosted repositories
            - `maven-releases` & `maven-snapshots`

    - `Group repositories`: Combines multiple hosted and proxy repositories into a single logical group,providing a unified view for clients.

### What we can do with Nexus Repository and its facts
- `Creation`: Create hosted, proxy, or group repositories.
- `Configuration`: Set policies for retention, cleanup, and indexing.
- `Security`: Control access to repositories and manage permissions.

- Artifact Formats:
    - `Support`: Nexus supports various artifact formats, including Maven, npm, Docker, and more.
    - `Configuration`: Configure specific settings for each format.

- Security:
    - `Authentication`: Configure authentication mechanisms like LDAP, Active Directory, or internal users.
    - `Authorization`: Define roles and permissions for different users.
    - `Encryption`: Protect sensitive data like passwords and credentials.

    - There are two types of user we can create on Nexus 
        - 1. Anonymous user  - They get only access to the repo contents (`GET - Read only` ), but they are restricted on other actions like create, delete, upload etc
        - 2. Regular user - Each `user` can have different `Roles` with different `Previleges`
    - There are some default `previleges` available for Nexus see the lists here https://help.sonatype.com/en/privileges.html
    - Generally `Jenkins` integrations are pretty common, where we want the Jenkins to upload the artifacts into Nexus, so we have to create a user `Jenkins` and assign a role with previlege as `create & read` - but not `delete`


- Best Practices
    - `Regular Cleanup`: Regularly clean up old or unused artifacts to optimize storage.
    - `Security Audits`: Conduct regular security audits to identify and address vulnerabilities.
    - `Performance Optimization`: Monitor performance and optimize settings as needed.
    - `Version Control`: Use version control for Nexus configuration to track changes and facilitate rollback.
    - `Backup and Recovery`: Implement a robust backup and recovery plan to protect your repository data.

- Promotion of repository
    - When we build an artifacts, that build does not get used in the production deployment
    - First it stores itself into staging repository
    - The tests are performed on the staging repo and if it passes all the tests, vulnerability tests,
    - The artifacts gets `promoted` into production repository to be used by prod deployment


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