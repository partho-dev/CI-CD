## INstall Docker on Ubuntu
- This will help to containerise other DevOps tool over it

- Update the package list: - `sudo apt update`

- Install prerequisite packages: `sudo apt install apt-transport-https ca-certificates curl software-properties-common -y`

- Add Docker’s GPG key:`curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`

- Add Docker’s repository:`sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"`

- Install Docker:`sudo apt install docker-ce -y`

- Verify Docker installation:`docker --version`

- Add your user to the docker group (optional but recommended to avoid using sudo for Docker commands):`sudo usermod -aG docker ${USER}`