# Makefile for setting up the environment and Spring Boot API For "https://github.com/PCSP-DevSolutions/Drive-API-Spring"

# Environment
ENV_FILE=/opt/.env
BASHRC=~/.bashrc
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
	@while IFS= read -r line; do [[ $$line =~ ^[^#]*= ]] && echo "export $$line" >> $(BASHRC); done < $(ENV_FILE)
	@echo "Adding aliases to $(BASHRC)"
	@echo "\n# Custom Aliases" >> $(BASHRC)
	@echo "alias brc='sudo nano ~/.bashrc'" >> $(BASHRC)
	@echo "alias egrep='egrep --color=auto'" >> $(BASHRC)
	@echo "alias fgrep='fgrep --color=auto'" >> $(BASHRC)
	@echo "alias grep='grep --color=auto'" >> $(BASHRC)
	@echo "alias l='ls -CF'" >> $(BASHRC)
	@echo "alias la='ls -A'" >> $(BASHRC)
	@echo "alias ll='ls -AlF'" >> $(BASHRC)
	@echo "alias ls='ls --color=auto'" >> $(BASHRC)
	@echo "alias sbrc='source ~/.bashrc'" >> $(BASHRC)
	@echo "alias slots='while true; do echo \"/dev/disk/by-slot/\":; ls -lA /dev/disk/by-slot/; echo \"/run/slots/\":; ls -lA /run/slots/; sleep 1; clear; done'" >> $(BASHRC)
	@echo "alias uldebug='udevadm control --log-priority=debug'" >> $(BASHRC)
	@echo "alias ulinfo='udevadm control --log-priority=info'" >> $(BASHRC)
	@echo "alias uload='udevadm control --reload-rules'" >> $(BASHRC)
	@source $(BASHRC)

install_packages:
	@echo "Installing required packages..."
	@sudo apt update
	@sudo apt install lsscsi make smartmontools nvme-cli hdparm htop libavahi-compat-libdnssd-dev openjdk-17-jre-headless maven git sg3-utils -y

clone_repo:
	@echo "Cloning repository..."
	@GITHUB_REPO="https://$${GITHUB_PAT}@github.com/PCSP-DevSolutions/Drive-API-Spring.git"; \
	git clone $$GITHUB_REPO $(CLONE_DIR)

setup_scripts:
	@echo "Copying udev rules and reloading..."
	@sudo cp -r $(CLONE_DIR)/scripts/rules/* /etc/udev/rules.d/
	@echo "Copying executable scripts to /usr/local/bin..."
	@sudo cp -r $(CLONE_DIR)/scripts/scripts/* /usr/local/bin/
	@sudo chmod +x /usr/local/bin/*
	@echo "Copying systemd services..."
	@sudo cp -r $(CLONE_DIR)/scripts/services/* /etc/systemd/system/

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