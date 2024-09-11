#!/bin/bash
##  It did not work for me ##
## Plz correct if it works for anyone ##
# Update and install necessary dependencies
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y openjdk-17-jdk postgresql postgresql-contrib unzip wget

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE USER sonar WITH PASSWORD 'sonar';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "ALTER USER sonar WITH SUPERUSER;"

# Download and install SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo unzip sonarqube-9.9.0.65466.zip
sudo mv sonarqube-9.9.0.65466 sonarqube

# Update SonarQube configuration
sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/g' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's|#sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube|sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube|g' /opt/sonarqube/conf/sonar.properties

# Set permissions
sudo chown -R ubuntu:ubuntu /opt/sonarqube
sudo chmod -R 755 /opt/sonarqube

# Create a systemd service for SonarQube
sudo bash -c 'cat <<EOT >> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=simple
User=ubuntu
Group=ubuntu
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
LimitNOFILE=65536
LimitNPROC=4096
TimeoutStartSec=5

[Install]
WantedBy=multi-user.target
EOT'

# Start and enable the SonarQube service
sudo systemctl daemon-reload
sudo systemctl start sonarqube
sudo systemctl enable sonarqube