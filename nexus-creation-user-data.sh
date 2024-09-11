### User Data script for Ec2

```
#!/bin/bash
# This script is designed to be used as user-data for an Ubuntu instance

# Update the package list
sudo apt-get update -y

# Install Java (OpenJDK 17)
sudo apt-get install -y openjdk-17-jre-headless

# Verify Java installation
if ! java -version; then
    echo "Java installation failed!"
    exit 1
fi

# Create a 'nexus' user with no login permissions and no home directory
sudo adduser --disabled-login --no-create-home --gecos "" nexus

# Create the sonatype-work directory
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/sonatype-work

# Navigate to /opt and download the Nexus installation files
cd /opt || exit
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract the downloaded tar.gz file
sudo tar -zxvf latest-unix.tar.gz

# Rename the extracted folder to 'nexus'
sudo mv nexus-3* nexus

# Change ownership of the Nexus directories
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

# Configure Nexus to run as the 'nexus' user
sudo bash -c 'echo "run_as_user=\"nexus\"" > /opt/nexus/bin/nexus.rc'

# Create a systemd service for Nexus to manage the Nexus service
sudo bash -c 'cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd to recognize the new Nexus service
sudo systemctl daemon-reload

# Enable the Nexus service to start on boot
sudo systemctl enable nexus

# Start the Nexus service
sudo systemctl start nexus

# Wait for Nexus to fully start up (this can take a few minutes)
sleep 120

# Check if Nexus is running
if systemctl status nexus | grep -q "active (running)"; then
    echo "Nexus is running!"
else
    echo "Nexus failed to start!"
    exit 1
fi

# Output the Nexus initial admin password (Optional)
if [ -f /opt/sonatype-work/nexus3/admin.password ]; then
    echo "Nexus initial admin password is located at: /opt/sonatype-work/nexus3/admin.password"
    cat /opt/sonatype-work/nexus3/admin.password
else
    echo "Nexus admin password file not found!"
fi

```