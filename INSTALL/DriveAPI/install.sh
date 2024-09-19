#!/bin/bash

# Bash Script for setting up the environment and Spring Boot API
# "https://github.com/PCSP-DevSolutions/Drive-API-Spring"

# Environment Variables
ENV_FILE="/opt/.env"
BASHRC="$HOME/.bashrc"
BASH_ALIASES="$HOME/.bash_aliases"
CLONE_DIR="/opt/drive-api-spring"
SERVICES_TO_ENABLE=("slotmapper.service")

# Function to check if the .env file exists
check_env() {
    if [ ! -f "$ENV_FILE" ]; then
        echo "Error: $ENV_FILE not found. Exiting..."
        exit 1
    fi
}

bashrc_export() {
    if grep -q "$1" "$BASHRC"; then
        echo "Already exported $1"
    else
        echo "export $1" >> "$BASHRC"
    fi
}

setup_environment() {
    echo "Setting up environment variables from $ENV_FILE"
    while IFS= read -r line; do
        # Only process lines that are not comments and have an '=' sign
        if [[ $line =~ ^[^#]*= ]]; then
            bashrc_export "$line"
        fi
    done < "$ENV_FILE"
    source "$BASHRC"
}

# Set up bash aliases
setup_aliases() {
    touch "$BASH_ALIASES"
    echo "Creating $BASH_ALIASES with custom aliases..."
    cat <<EOL >> "$BASH_ALIASES"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# $BASH_ALIASES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Description:
# This file contains custom aliases to improve efficiency in the bash shell.
#
# Notes:
# - Avoid alias names that conflict with existing system commands.
# - Use descriptive names for aliases to maintain clarity.
#
# Created on: 09-11-2024
# Author: Matt
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bash Configuration Aliases
alias brc='sudo nano ~/.bashrc'
alias sbrc='source ~/.bashrc'
alias bal='sudo nano ~/.bash_aliases'

# ls Command Enhancements
alias ll='ls -AlF'
alias la='ls -A'
alias l='ls -CF'

# udevadm Aliases
alias uload='udevadm control --reload-rules'
alias ulinfo='udevadm control --log-priority=info'
alias uldebug='udevadm control --log-priority=debug'

# Monitor Slot Aliases
alias slots='while true; do echo "/dev/disk/by-slot/"; ll /dev/disk/by-slot/; sleep 1; clear; done'
alias slots-long='while true; do echo "/dev/disk/by-slot/"; ll /dev/disk/by-slot/; echo "/run/slots/"; ll /run/slots/; sleep 1; clear; done'

# Alias to pull the latest API code and run it
# Alias to restore local changes, pull the latest API code, and run it
alias pullapi='cd /opt/drive-api-spring/ && git pull && chmod +x scripts/bin/* && mvn clean package && mv target/*.jar target/drive-api.jar && chmod +x target/drive-api.jar'
alias rpullapi='cd /opt/drive-api-spring/ && git restore . && git pull && chmod +x scripts/bin/* && mvn clean package && mv target/*.jar target/drive-api.jar && chmod +x target/drive-api.jar'

# Alias to run the compiled JAR
# Alias to clean, recompile, and rename the JAR
alias runapi='java -jar /opt/drive-api-spring/target/drive-api.jar'
alias compileapi='cd /opt/drive-api-spring/ && mvn clean package && mv target/*.jar target/drive-api.jar && chmod +x target/drive-api.jar'

EOL
    source "$BASHRC"
    echo "Successfully updated bashrc and bash_aliases"
}


# Synchronize system time
sync_time() {
    echo "Synchronizing system time with timedatectl..."
    sudo timedatectl set-ntp true
    sudo timedatectl set-timezone America/Detroit
    if sudo timedatectl status | grep -q "NTP synchronized: yes"; then
        echo "Time synchronized successfully."
    else
        echo "Time synchronization failed."
    fi
}

# Install required packages
install_packages() {
    echo "Installing required packages..."
    sudo apt update
    sudo apt install make lsscsi smartmontools nvme-cli hdparm htop libavahi-compat-libdnssd-dev openjdk-17-jre-headless maven git sg3-utils inxi gcc g++ libxml2-utils libudev-dev mariadb-server -y
    echo "Successfully installed required packages"
}

# Clone repository
clone_repo() {
    echo "Cloning repository..."
    GITHUB_PAT=$(grep '^GITHUB_PAT=' "$ENV_FILE" | cut -d '=' -f2)
    GITHUB_REPO="https://$GITHUB_PAT@github.com/PCSP-DevSolutions/Drive-API-Spring.git"
    git clone "$GITHUB_REPO" "$CLONE_DIR"
    chmod +x "$CLONE_DIR/scripts/udev/"*
    chmod +x "$CLONE_DIR/scripts/bin/"*
    chmod +x "$CLONE_DIR/scripts/services/"*
    echo "Successfully cloned repository to $CLONE_DIR"
}

# Set up udev rules and scripts
setup_scripts() {
    echo "Copying udev rules and reloading..."
    # Symlink the udev rules to /etc/udev/rules.d/
    sudo ln -s "$CLONE_DIR/scripts/udev/"* /etc/udev/rules.d/
    
    # Symlink the systemd services to /etc/systemd/system/
    sudo ln -s "$CLONE_DIR/scripts/services/"* /etc/systemd/system/
    echo "Successfully copied scripts and services"

    # Add /opt/drive-api-spring/scripts/bin to PATH
    echo "Adding /opt/drive-api-spring/scripts/bin to PATH..."
    bashrc_export "PATH=\$PATH:/opt/drive-api-spring/scripts/bin"
    source "$BASHRC"
}

# Reload udev rules
reload_udev_rules() {
    echo "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger
}

# Enable and start services
setup_services() {
    systemctl daemon-reload
    for service in "${SERVICES_TO_ENABLE[@]}"; do
        echo "Starting and enabling $service..."
        sudo systemctl start "$service"
        sudo systemctl enable "$service"
    done
}

# Set up MariaDB with a user and database
setup_mariadb() {
    echo "Setting up MariaDB..."
    # Ensure MariaDB is running
    sudo systemctl start mariadb
    sudo systemctl enable mariadb

    # Extract database details from .env
    DB_HOST=$(grep '^DRIVEAPI_DB_HOST=' "$ENV_FILE" | cut -d '=' -f2)
    DB_USER=$(grep '^DRIVEAPI_DB_USER=' "$ENV_FILE" | cut -d '=' -f2)
    DB_PASSWORD=$(grep '^DRIVEAPI_DB_PASSWORD=' "$ENV_FILE" | cut -d '=' -f2)
    DB_NAME=$(grep '^DRIVEAPI_DB_NAME=' "$ENV_FILE" | cut -d '=' -f2)

    # Secure MariaDB installation (this can be customized further if needed)
    sudo mysql_secure_installation <<EOF

n
y
y
y
y
EOF

    # Create user, database, and grant privileges
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
    sudo mysql -e "FLUSH PRIVILEGES;"
    
    echo "MariaDB setup completed with user $DB_USER and database $DB_NAME"
}

# Step 11: Compile Spring Boot application into a JAR and make it executable
setup_step_11() {
    echo "Compiling Spring Boot application into drive-api.jar..."
    cd "$CLONE_DIR" || exit

    # Clean and package the application into a JAR
    mvn clean package

    # Move the packaged JAR to a specific name (drive-api.jar)
    TARGET_DIR="$CLONE_DIR/target"
    if [ -f "$TARGET_DIR"/*.jar ]; then
        mv "$TARGET_DIR"/*.jar "$TARGET_DIR/drive-api.jar"
        echo "Renamed JAR to drive-api.jar."
    else
        echo "Error: JAR file not found."
        exit 1
    fi

    # Make the JAR executable
    chmod +x "$TARGET_DIR/drive-api.jar"
    echo "drive-api.jar is now executable."
}

main() {
    echo "Starting setup process..."
    sleep 1
    echo "Step 1: Checking for .env file..."
    check_env
    sleep 1
    echo "Step 2: Setting up environment variables..."
    setup_environment
    sleep 1
    echo "Step 3: Setting up aliases..."
    setup_aliases
    sleep 1
    echo "Step 4: Synchronizing system time..."
    sync_time
    sleep 1
    echo "Step 5: Installing required packages..."
    install_packages
    sleep 1
    echo "Step 6: Cloning the repository..."
    clone_repo
    sleep 1
    echo "Step 7: Setting up udev rules and scripts..."
    setup_scripts
    sleep 1
    echo "Step 8: Reloading udev rules..."
    reload_udev_rules
    sleep 1
    echo "Step 9: Setting up services..."
    setup_services
    sleep 1
    echo "Step 10: Setting up MariaDB with user and database..."
    setup_mariadb
    sleep 1
    echo "Step 11: Compiling Spring Boot application and making it executable..."
    setup_step_11
    echo "Setup process completed."
}

main

