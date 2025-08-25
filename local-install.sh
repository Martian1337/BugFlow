#!/bin/bash

# Install Git and curl
sudo apt install -y git curl
git --version

# Install SDKman to manage or install multiple versions of java - https://sdkman.io/usage#installdefault
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java

# Add Jenkins repo, GPG key and install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update --fix-missing
sudo apt-get install jenkins -y
sudo sed -i 's/HTTP_PORT=8080/HTTP_Port=8080/' /etc/default/jenkins
sudo usermod -aG docker jenkins

# Start Jenkins
sudo systemctl enable jenkins

# Install SonarScanner
# Confirm most current scanner version in filename - https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonarscanner
sudo ln -s /opt/sonarscanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
rm sonar-scanner-cli-5.0.1.3006-linux.zip

# Update the system and install necessary packages
sudo apt update
# Install languages and dependencies
sudo apt install -y maven python3 ruby php golang unzip nodejs npm -y
curl --proto '=https' --tlsv1.2 -ssf https://sh.rustup.rs | sh -s -- -y

# Install Snyk
sudo npm install -g snyk

# Install ZAP
sudo apt-get install zaproxy

# Install AWS cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm awscli-exe-linux-x86_64.zip && rm -rv aws

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.18.3
# Confirm most current release at https://github.com/aquasecurity/trivy/releases
# sudo wget https://github.com/aquasecurity/trivy/releases/download/v0.47.0/trivy_0.47.0_Linux-64bit.tar.gz
# sudo tar zxvf trivy_0.47.0_Linux-64bit.tar.gz
# sudo chmod +x /usr/local/bin/trivy


# Install Docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  bookworm stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Install Kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
# Minikube Install and Configure
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x ./minikube
sudo mv ./minikube /usr/local/bin/
sudo systemctl enable docker --now
sudo chmod 666 /var/run/docker.sock


# Manually download Kubernetes-cd
curl -OJL https://get.jenkins.io/plugins/kubernetes-cd/1.0.0/kubernetes-cd.hpi
