
## SOnarkube - Static code analysis
If we plan to configure sonarqube webserver and its data base in two different servers
- we have to make sure, both the servers are of same time sync 
- Execute this `timedatectl` on both the web & db server



### Why do we use SonarQube?
- SonarQube is used to automatically analyze the quality of your source code. 
- It helps identify `bugs`, `security vulnerabilities`, and `code smells` (bad coding practices) that could lead to maintainability issues. 
- By using SonarQube, developers and organizations can ensure that their code is reliable, maintainable, and secure.



### What are the components in SonarQube?

- ![SonarQube-Arch](https://github.com/user-attachments/assets/6d49d9ec-3a27-4747-9935-ab2e6223abf3)

- `SonarQube Server`: This is the central component that processes analysis results and provides a user interface for viewing the reports.
- `Database`: Stores the analysis results, configurations, and settings. Supported databases include PostgreSQL, MySQL, Oracle, and Microsoft SQL Server.
- `Scanner`: A tool that collects the source code and sends it to the SonarQube Server for analysis. It runs as a part of your build process.
- `Web Interface`: The frontend that allows users to interact with the analysis results, manage projects, and configure settings.
- `Compute Engine`: The part of the server that processes the analysis reports and computes the metrics.

## Installation of Sonar on Ubuntu (Manual Process)
- **Update** : `sudo apt update && sudo apt upgrade -y`
- **install java & postgress** - `sudo apt install openjdk-17-jdk postgresql unzip wget -y`
- **Check if Java is installed** - `java -version`

### Setup the Postgres
- `sudo -i -u postgres`
- **create db**  - `psql -c "CREATE DATABASE sonarqube;"`
- **create db user** - `psql -c "CREATE USER sonaruser WITH ENCRYPTED PASSWORD 'secure_password';"`
- **set permission** - `psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonaruser;"`

- Grant previlege to public schema
```
psql
GRANT ALL PRIVILEGES ON SCHEMA public TO sonaruser;
ALTER USER sonaruser WITH SUPERUSER;
\q
```

- **exit** `exit`

###  Install and Configure SonarQube
- download sonar 9 :
- cd /opt
- sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip

- Unzip  (`sudo apt install unzip -y`)
```
sudo unzip sonarqube-9.9.0.65466.zip
sudo mv sonarqube-9.9.0.65466 sonarqube
```

- Change ownership - `sudo chown -R ubuntu:ubuntu /opt/sonarqube`

### Configure SonarQube to connect to PostgreSQL: Edit the sonar.properties file to configure the database connection:

- sudo vi /opt/sonarqube/conf/sonar.properties

- and update these lines
```
sonar.jdbc.username=sonaruser
sonar.jdbc.password=secure_password
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
```

### Allow SonarQube to listen on all network interfaces: 
- Also in `sonar.properties`, modify or add these lines:
```
sonar.web.host=0.0.0.0
sonar.web.port=9000
```


### Configure SonarQube as a Systemd Service
- sudo vi /etc/systemd/system/sonarqube.service
- Add these contents
```
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=ubuntu
Group=ubuntu
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

- Reload and enable SOnar service 
```
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube
```

- Verify the setup - sudo systemctl status sonarqube
- Check if its listening on port 9000 - sudo netstat -plnt | grep 9000

- Logs 
    - sudo tail -f /opt/sonarqube/logs/sonar.log
    - sudo tail -f /opt/sonarqube/logs/web.log

- Access the server UI - http://<your-ec2-public-ip>:9000

## Test the code quality check manually
- We need two different servers, one for scanning (Sonar client - Generally its Jenkins) other is the real server for Sonar
- But, for our today task, we will use one single server as both server and scanner client
- We will clone our source code manually on our server and execute the sonar scan and see the report on the Sonar UI - sonar_ip:9000

- On the same above ubuntu server, lets install and configure the `sonar scanner`

## Installation of sonar scanner on the same server
- cd /opt
- Download scanner - `sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip`
- unzip - `sudo unzip sonar-scanner-cli-4.8.0.2856-linux.zip`
- rename the scanner - `sudo mv sonar-scanner-4.8.0.2856-linux sonar-scanner`
- Chnage iwnership - `sudo chown -R ubuntu:ubuntu /opt/sonar-scanner`

### Configure the scanner 
- `sudo vi /opt/sonar-scanner/conf/sonar-scanner.properties`
- add the path of Java on the above file - `sonar.java.binaries=./`
- Add the sonar scanner on system path
- `sudo nano /etc/profile.d/sonar-scanner.sh` & add this `export PATH="$PATH:/opt/sonar-scanner/bin"`
- Make the file executable - `sudo chmod +x /etc/profile.d/sonar-scanner.sh`
- Load the environment variabel - `source /etc/profile.d/sonar-scanner.sh`

- Check if the scanner installation was successful - `sonar-scanner -v`

### Now, manually scan the code
- Clone the source code on the `sonar server/scanner`
- `git clone https://github.com/partho-dev/nextjs.git`
- navigate to the project - `cd nextjs/Next-Project-with-Unit&E2ETest`
- Create `sonar-project.properties` and keep it in the same folder as the source code (`nextjs/Next-Project-with-Unit&E2ETest`)
- Add these content there
```
sonar.projectKey=nextjs-project-key
sonar.projectName=Next.js Project with Unit & E2E Test
sonar.projectVersion=1.0
sonar.sources=.
sonar.host.url=http://localhost:9000
sonar.login=your_sonarqube_token
```
- `projectKey` & `login token` we have to get from the sonar server UI

- **Project Key**
- <img width="520" alt="sonar-project-key" src="https://github.com/user-attachments/assets/082f47ad-a848-4dfe-a705-63d017f7a9b0">

- **Token**
- <img width="1095" alt="sonar-token" src="https://github.com/user-attachments/assets/ff2260a8-c74f-4fd3-9da9-38e0b2bdf9b6">

- To execute the scan 
- Go to the project directory - Ex: `cd nextjs/Next-Project-with-Unit&E2ETest` 
- Command : `sonar-scanner`

- To see the result, go to the server - `IP:9000`
- <img width="1451" alt="sonar-result" src="https://github.com/user-attachments/assets/40ae1318-7ff1-4e38-af94-f15ec91b8573">

## How to connect the sonar server with Jenkins
-	`Create token` on Sonar which would be used on Jenkins 
    - Admission – Security – Users – Generate a Token

-	To `Add the Sonar Token in Jenkins` : 
    - In the `Jenkins`: Manage Jenkins - credentials – global – add credentials – secret Text – Add Sonar Token in “secret” field – Give any ID to remember that its for Sonar
-	To Add the `Sonar Server IP` in Jenkins : In the Jenkins: Manage Jenkins – systems – select SonarQube server(make sure the plugins are installed already) – name(sonar-server) – url(sonar_server_ip:9000) – Add the sonar token

`----------------------------------------------------------------------------------------------------------------------------`

## Manual process is time consuming and error oriented.

### Dockrise the sonar on local with the image Sonar provides is the best way
- 1. First create a postgress container 
- `docker run -d --name sonarqube-db -e POSTGRES_USER=sonar -e POSTGRES_PASSWORD=sonar -e POSTGRES_DB=sonarqube postgres:alpine`

- 2. Create the sonarqube container and link that with the postgress container
- using `donarqube` docker image
- `docker run -d --name sonarqube -p 9000:9000 --link sonarqube-db:db -e SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonarqube -e SONAR_JDBC_USERNAME=sonar -e SONAR_JDBC_PASSWORD=sonar sonarqube`

**Step1**
- <img width="1204" alt="sonar-qube-dockerise" src="https://github.com/user-attachments/assets/2451a05c-c834-4c9b-bbe7-af1538bbb027">

**step2**
- <img width="910" alt="sonar-qube-dockerise-local" src="https://github.com/user-attachments/assets/952f84a1-847a-4f23-b0ab-529ec634eb54">


`----------------------------------------------------------------------------------------------------------------------------`

## Contaianerised the Sonar
- See the deployment files inside the folder `sonarQube-container-eks` 
- From this link - `https://github.com/partho-dev/CI-CD/tree/main/sonarQube-container-eks`

### For Local K8s deployment (minikube or kind)
- 1. kubectl apply -f deployment-postgreSQL.yaml
- 2. kubectl apply -f deployment-sonar.yaml

### For cloud like EKS or self hosted k8s
- We can expose using ingress object, so we will use
- 1. kubectl apply -f deployment-postgreSQL.yaml
- 2. deployment-sonar-ingress.yaml

- <img width="665" alt="sonar-containerised" src="https://github.com/user-attachments/assets/2f1db966-d7cf-4887-b5d5-b5dad507640e">

