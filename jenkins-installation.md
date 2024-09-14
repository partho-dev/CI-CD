## Jenkins installation on Ubuntu 22 (Manual approach) on Ec2 
- Update the OS - sudo apt update && sudo apt upgrade -y
- install JAVA (Change to latest version if needed) - `sudo apt-get install openjdk-17-jdk` 
- to install Jenkins securely, add the GCP Key - 
```
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

```
- Add Jenkins repo
```
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
```
- Update the local repo again - `sudo apt update`

- install Jenkins - `sudo apt install jenkins -y`
- start Jenkins - `sudo systemctl start jenkins`
- ENbale to start on boot - `sudo systemctl enable jenkins`

- Access Jenkins - `http://your_server_ip:8080`

`===========================================================================================`

## Installation of Jenkins thrlugh Docker
- Make sure docjer is installed on the system
- Pull the Jenkins Docker image:`docker pull jenkins/jenkins:lts`

- Run the Jenkins container:`docker run -d -p 8080:8080 -p 50000:50000 --name jenkins -v jenkins_home:/var/jenkins_home jenkins jenkins:lts`
```    
-p 8080:8080: Exposes Jenkins web interface on port 8080.
-p 50000:50000: Exposes the port for Jenkins agent communication.
-v jenkins_home:/var/jenkins_home: Persists Jenkins data.
```

- Check that Jenkins is running: `docker ps`
- Access Jenkins by navigating to your server's IP or hostname in a web browser: `http://your_server_ip:8080`
- Unlock Jenkins and Complete Setup: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`


`===========================================================================================`

## Jenkins as a container in K8s (EKS)
- Get the deployment files here - 
- Execute the kubectl command to deploy the tools
- create namespace(as on my deployment file, I have mentioned the Jenkins to use namespace) - `kubectl create namespace devops-tools`
- apply the deployment file - `kubectl apply -f jenkins-deployment.yaml`
- Check the deployment status - `kubectl get pods -n devops-tools`

### Access the containerised Jenkins 
- for `loadbalancer` service type, find external IP - `kubectl get svc -n devops-tools`
- Then access - `http://<EXTERNAL-IP>:8080`
- For `NodePort` - `http://<node-ip>:<node-port>`

- Find the jenkins pass - `kubectl exec --namespace devops-tools -it $(kubectl get pods --namespace devops-tools -l "app=jenkins" -o jsonpath="{.items[0].metadata.name}") -- cat /var/jenkins_home/secrets/initialAdminPassword`