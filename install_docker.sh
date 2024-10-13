#!/bin/bash

# install_docker.sh

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to uninstall Docker
uninstall_docker() {
    echo "Uninstalling existing Docker installation..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc
    sudo apt-get purge -y docker docker-engine docker.io containerd runc
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    sudo add-apt-repository \
       "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    if ! command_exists docker; then
        echo "Error: Docker installation failed."
        return 1
    fi

    # Add user to docker group
    sudo usermod -aG docker "$SUDO_USER"
}

# Function to uninstall Docker Compose
uninstall_docker_compose() {
    echo "Uninstalling existing Docker Compose installation..."
    sudo rm -f /usr/local/bin/docker-compose
}

# Function to install Docker Compose
install_docker_compose() {
    echo "Installing Docker Compose..."
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    if ! command_exists docker-compose; then
        echo "Error: Docker Compose installation failed."
        return 1
    fi
}

# Function to uninstall Git
uninstall_git() {
    echo "Uninstalling existing Git installation..."
    sudo apt-get remove -y git
    sudo apt-get purge -y git
}

# Function to install Git
install_git() {
    echo "Installing Git..."
    sudo apt-get update
    sudo apt-get install -y git

    if ! command_exists git; then
        echo "Error: Git installation failed."
        return 1
    fi
}

# Main installation flow with error handling
echo "Starting Docker installation..."

if ! install_docker; then
    echo "Docker installation failed. Attempting to uninstall and reinstall..."
    uninstall_docker
    if ! install_docker; then
        echo "Error: Docker installation failed after reinstallation attempt."
        exit 1
    fi
fi

echo "Docker installed successfully."

echo "Starting Docker Compose installation..."

if ! install_docker_compose; then
    echo "Docker Compose installation failed. Attempting to uninstall and reinstall..."
    uninstall_docker_compose
    if ! install_docker_compose; then
        echo "Error: Docker Compose installation failed after reinstallation attempt."
        exit 1
    fi
fi

echo "Docker Compose installed successfully."

echo "Starting Git installation..."

if ! install_git; then
    echo "Git installation failed. Attempting to uninstall and reinstall..."
    uninstall_git
    if ! install_git; then
        echo "Error: Git installation failed after reinstallation attempt."
        exit 1
    fi
fi

echo "Git installed successfully."
