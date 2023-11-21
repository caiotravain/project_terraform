#!/bin/sh

wait_for_dpkg() {
    while sudo lsof /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Waiting for other software managers to finish..."
        sleep 2
    done
}

install_docker() {
    wait_for_dpkg
    sudo apt-get update
    wait_for_dpkg
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
    wait_for_dpkg
    sudo apt-get update
    wait_for_dpkg
    sudo apt-get install -y docker-ce
}

start_docker() {
    if [ -x "$(command -v docker)" ]; then
        echo "Docker already installed, checking status..."
        if ! systemctl is-active --quiet docker; then
            echo "Starting Docker..."
            sudo systemctl start docker
        else
            echo "Docker is already running."
        fi
        echo "Enabling Docker to start on boot..."
        sudo systemctl enable docker
    else
        echo "Docker not installed, installing..."
        install_docker
        echo "Starting Docker..."
        sudo systemctl start docker
        echo "Enabling Docker to start on boot..."
        sudo systemctl enable docker
    fi
}

pull_and_run() {
    sudo docker pull andrebrito16/api-hits-logger
    sudo docker run -d -p 3000:3000 -e DATABASE_URL=${POSTGRES_CONNECTION_STRING} --restart always --name app-hono andrebrito16/api-hits-logger
}

start_docker
pull_and_run

# Reboot the machine to ensure all settings take effect properly
echo "Rebooting the machine..."
sudo reboot
