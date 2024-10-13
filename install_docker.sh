#!/bin/bash

# install_docker.sh

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run with administrative privileges. Please run with sudo."
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to uninstall Docker
uninstall_docker() {
    echo "Uninstalling existing Docker installation..."
    if [[ "$OS_NAME" == "ubuntu" || "$OS_NAME" == "debian" ]]; then
        sudo apt-get remove -y docker docker-engine docker.io containerd runc
        sudo apt-get purge -y docker docker-engine docker.io containerd runc
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
    elif [[ "$OS_NAME" == "arch" ]]; then
        sudo pacman -Rns --noconfirm docker docker-compose containerd
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
    elif [[ "$OS_NAME" == "fedora" || "$OS_NAME" == "centos" ]]; then
        sudo yum remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
    else
        echo "Unsupported OS for automatic Docker uninstallation."
    fi
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."

    if [[ "$OS_NAME" == "ubuntu" || "$OS_NAME" == "debian" ]]; then
        sudo apt-get update
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common

        curl -fsSL https://download.docker.com/linux/$OS_NAME/gpg | sudo apt-key add -

        sudo add-apt-repository \
           "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$OS_NAME \
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

    elif [[ "$OS_NAME" == "arch" ]]; then
        sudo pacman -Syu --noconfirm
        sudo pacman -Sy --noconfirm docker

        if ! command_exists docker; then
            echo "Error: Docker installation failed."
            return 1
        fi

        # Enable and start Docker service
        sudo systemctl enable docker
        sudo systemctl start docker

        # Add user to docker group
        sudo usermod -aG docker "$SUDO_USER"

    elif [[ "$OS_NAME" == "fedora" ]]; then
        sudo dnf -y remove docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine

        sudo dnf -y install dnf-plugins-core

        sudo dnf config-manager \
            --add-repo \
            https://download.docker.com/linux/fedora/docker-ce.repo

        sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

        if ! command_exists docker; then
            echo "Error: Docker installation failed."
            return 1
        fi

        # Start Docker
        sudo systemctl start docker
        sudo systemctl enable docker

        # Add user to docker group
        sudo usermod -aG docker "$SUDO_USER"

    elif [[ "$OS_NAME" == "centos" ]]; then
        sudo yum remove -y docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine

        sudo yum install -y yum-utils

        sudo yum-config-manager \
            --add-repo \
            https://download.docker.com/linux/centos/docker-ce.repo

        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

        if ! command_exists docker; then
            echo "Error: Docker installation failed."
            return 1
        fi

        # Start Docker
        sudo systemctl start docker
        sudo systemctl enable docker

        # Add user to docker group
        sudo usermod -aG docker "$SUDO_USER"

    elif [[ "$OS_NAME" == "opensuse-leap" || "$OS_NAME" == "sles" ]]; then
        sudo zypper refresh
        sudo zypper install -y docker

        if ! command_exists docker; then
            echo "Error: Docker installation failed."
            return 1
        fi

        # Start Docker
        sudo systemctl start docker
        sudo systemctl enable docker

        # Add user to docker group
        sudo usermod -aG docker "$SUDO_USER"

    elif grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
        echo "Detected WSL. Installing Docker Desktop is recommended."
        echo "Please install Docker Desktop for Windows and enable WSL integration."
        return 1
    else
        echo "Unsupported OS for automatic Docker installation."
        return 1
    fi
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
    if [[ -z "$DOCKER_COMPOSE_VERSION" ]]; then
        DOCKER_COMPOSE_VERSION="2.20.2"
    fi

    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        ARCH="amd64"
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        ARCH="arm64"
    fi

    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$ARCH" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    if ! command_exists docker-compose; then
        echo "Error: Docker Compose installation failed."
        return 1
    fi
}

# Function to uninstall Git
uninstall_git() {
    echo "Uninstalling existing Git installation..."
    if [[ "$OS_NAME" == "ubuntu" || "$OS_NAME" == "debian" ]]; then
        sudo apt-get remove -y git
        sudo apt-get purge -y git
    elif [[ "$OS_NAME" == "arch" ]]; then
        sudo pacman -Rns --noconfirm git
    elif [[ "$OS_NAME" == "fedora" || "$OS_NAME" == "centos" ]]; then
        sudo yum remove -y git
    else
        echo "Unsupported OS for automatic Git uninstallation."
    fi
}

# Function to install Git
install_git() {
    echo "Installing Git..."
    if [[ "$OS_NAME" == "ubuntu" || "$OS_NAME" == "debian" ]]; then
        sudo apt-get update
        sudo apt-get install -y git
    elif [[ "$OS_NAME" == "arch" ]]; then
        sudo pacman -Sy --noconfirm git
    elif [[ "$OS_NAME" == "fedora" || "$OS_NAME" == "centos" ]]; then
        sudo yum install -y git
    else
        echo "Unsupported OS for automatic Git installation."
        return 1
    fi

    if ! command_exists git; then
        echo "Error: Git installation failed."
        return 1
    fi
}

# Detect OS Distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=$VERSION_ID
    echo "Detected OS: $PRETTY_NAME"
else
    echo "Error: Cannot detect the operating system."
    exit 1
fi

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
