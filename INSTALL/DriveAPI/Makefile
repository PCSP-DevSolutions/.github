# Makefile for setting up the environment and Spring Boot API For "https://github.com/PCSP-DevSolutions/Drive-API-Spring"

# Environment
ENV_FILE=/opt/.env
BASHRC=~/.bashrc
BASH_ALIASES=~/.bash_aliases
CLONE_DIR=/opt/drive-api-spring
SERVICES_TO_ENABLE := slotmapper.service  

.PHONY: all check_env setup_environment install_packages clone_repo setup_scripts setup_services reload_udev_rules

all: check_env setup_environment install_packages clone_repo setup_scripts reload_udev_rules setup_services

# Check if the .env file exists
check_env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Error: $(ENV_FILE) not found. Exiting..."; \
		exit 1; \
	fi

setup_environment:
	@echo "Setting up environment variables from $(ENV_FILE)"
	@bash -c 'while IFS= read -r line; do [[ $$line =~ ^[^#]*= ]] && echo "export $$line" >> $(BASHRC); done < $(ENV_FILE)'
	@bash -c 'source $(BASHRC)'

setup_aliases:
	@bash -c 'touch $(BASH_ALIASES)'
	@echo "Creating $(BASH_ALIASES) with custom aliases..."
	@echo "\n# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $(BASH_ALIASES)
	@echo "# $(BASH_ALIASES)" >> $(BASH_ALIASES)
	@echo "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $(BASH_ALIASES)
	@echo "# Description:" >> $(BASH_ALIASES)
	@echo "# This file contains custom aliases to improve efficiency in the bash shell." >> $(BASH_ALIASES)
	@echo "#" >> $(BASH_ALIASES)
	@echo "# Notes:" >> $(BASH_ALIASES)
	@echo "# - Avoid alias names that conflict with existing system commands." >> $(BASH_ALIASES)
	@echo "# - Use descriptive names for aliases to maintain clarity." >> $(BASH_ALIASES)
	@echo "#" >> $(BASH_ALIASES)
	@echo "# Created on: 09-11-2024" >> $(BASH_ALIASES)
	@echo "# Author: Matt" >> $(BASH_ALIASES)
	@echo "# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $(BASH_ALIASES)
	@echo "" >> $(BASH_ALIASES)
	@echo "# Bash Configuration Aliases" >> $(BASH_ALIASES)
	@echo "alias brc='sudo nano ~/.bashrc'" >> $(BASH_ALIASES)
	@echo "alias sbrc='source ~/.bashrc'" >> $(BASH_ALIASES)
	@echo "alias bal='sudo nano $(BASH_ALIASES)'" >> $(BASH_ALIASES)
	@echo "" >> $(BASH_ALIASES)
	@echo "# ls Command Enhancements" >> $(BASH_ALIASES)
	@echo "alias ll='ls -AlF'" >> $(BASH_ALIASES)
	@echo "alias la='ls -A'" >> $(BASH_ALIASES)
	@echo "alias l='ls -CF'" >> $(BASH_ALIASES)
	@echo "" >> $(BASH_ALIASES)
	@echo "# udevadm Aliases" >> $(BASH_ALIASES)
	@echo "alias uload='udevadm control --reload-rules'" >> $(BASH_ALIASES)
	@echo "alias ulinfo='udevadm control --log-priority=info'" >> $(BASH_ALIASES)
	@echo "alias uldebug='udevadm control --log-priority=debug'" >> $(BASH_ALIASES)
	@echo "" >> $(BASH_ALIASES)
	@echo "# Monitor Slot Aliases" >> $(BASH_ALIASES)
	@echo "alias slots='while true; do echo \"/dev/disk/by-slot/\":; ll /dev/disk/by-slot/; sleep 1; clear; done'" >> $(BASH_ALIASES)
	@echo "alias slots-long='while true; do echo \"/dev/disk/by-slot/\":; ll /dev/disk/by-slot/; echo \"/run/slots/\":; ll /run/slots/; sleep 1; clear; done'" >> $(BASH_ALIASES)
	@bash -c 'source $(BASHRC)'
	@bash -c 'echo "Sucessfully updated bashrc and bash_aliases"; sleep 2'

sync_time:
	@echo "Synchronizing system time with timedatectl..."
	@sudo timedatectl set-ntp true
	@sudo timedatectl set-timezone America/Detroit
	@sudo timedatectl status | grep "NTP synchronized:" | grep -q "yes" && echo "Time synchronized successfully." || echo "Time synchronization failed."
	@bash -c 'echo "Sucessfully synchronized system time"; sleep 2'

install_packages:
	@echo "Installing required packages..."
	@sudo apt update
	@sudo apt install lsscsi smartmontools nvme-cli hdparm htop libavahi-compat-libdnssd-dev openjdk-17-jre-headless maven git sg3-utils inxi gcc g++ libxml2-utils libudev-dev -y
	@bash -c 'echo "Sucessfully installed required packages"; sleep 2'

clone_repo:
	@echo "Cloning repository..."
	@GITHUB_PAT=$$(grep '^GITHUB_PAT=' $(ENV_FILE) | cut -d '=' -f2); \
	GITHUB_REPO="https://$$GITHUB_PAT@github.com/PCSP-DevSolutions/Drive-API-Spring.git"; \
	git clone $$GITHUB_REPO $(CLONE_DIR)
	@bash -c 'echo "Sucessfully cloned repository to $(CLONE_DIR)"; sleep 2'

setup_scripts:
	@echo "Copying udev rules and reloading..."
	@sudo cp -r $(CLONE_DIR)/scripts/rules/* /etc/udev/rules.d/
	@echo "Copying executable scripts to /usr/local/bin..."
	@sudo cp -r $(CLONE_DIR)/scripts/scripts/* /usr/local/bin/
	@sudo chmod +x /usr/local/bin/*
	@echo "Copying systemd services..."
	@sudo cp -r $(CLONE_DIR)/scripts/services/* /etc/systemd/system/
	@bash -c 'echo "Sucessfully copied scripts and services"; sleep 2'

reload_udev_rules:
	@echo "Reloading udev rules..."
	@sudo udevadm control --reload-rules
	@sudo udevadm trigger

setup_services:
	@for service in $(SERVICES_TO_ENABLE); do \
		echo "Starting and enabling $$service..."; \
		sudo systemctl start $$service; \
		sudo systemctl enable $$service; \
	done
