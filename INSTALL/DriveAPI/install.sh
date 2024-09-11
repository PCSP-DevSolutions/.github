#!/bin/bash


curl -o /opt/Makefile https://raw.githubusercontent.com/PCSP-DevSolutions/.github/main/INSTALL/DriveAPI/Makefile
sleep 1
sudo chmod +x /opt/Makefile
sleep 1
cd /opt && make
