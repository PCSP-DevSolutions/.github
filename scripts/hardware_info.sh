#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script requires root privileges. Please run with sudo."
    exit 1
fi

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$NAME
    VERSION=$VERSION_ID
    ID=$ID
else
    echo "❌ Could not detect distribution"
    exit 1
fi

# Function to install required packages based on distribution
install_required_packages() {
    echo "📦 Checking and installing required packages..."
    
    case $ID in
        "ubuntu"|"debian")
            PACKAGES="dmidecode smartmontools inxi lshw"
            apt-get update
            apt-get install -y $PACKAGES
            ;;
        "centos"|"rhel"|"fedora"|"rocky"|"almalinux"|"ol")
            PACKAGES="dmidecode smartmontools inxi lshw"
            if command -v dnf &> /dev/null; then
                dnf install -y $PACKAGES
            else
                yum install -y $PACKAGES
            fi
            ;;
        "arch"|"manjaro")
            PACKAGES="dmidecode smartmontools inxi lshw"
            pacman -Sy --noconfirm $PACKAGES
            ;;
        *)
            echo "⚠️ Unsupported distribution: $DISTRO ($ID)"
            echo "Please install the following packages manually:"
            echo "- dmidecode"
            echo "- smartmontools"
            echo "- inxi"
            echo "- lshw"
            read -p "Press Enter to continue or Ctrl+C to exit..."
            ;;
    esac
}

# Install required packages
install_required_packages

OUTPUT="hardware_report_$(hostname)_$(date +%Y-%m-%d_%H-%M-%S).txt"

echo "Gathering system hardware info... Output will be saved to: $OUTPUT"
echo "Hardware Report - $(hostname) - $(date)" > "$OUTPUT"
echo "==================================================" >> "$OUTPUT"

# CPU Info
echo -e "\n🧠 CPU Info" >> "$OUTPUT"
echo "------------------------" >> "$OUTPUT"
lscpu >> "$OUTPUT"
echo -e "\nCPU Model: $(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)" >> "$OUTPUT"
echo "CPU Count: $(grep -c ^processor /proc/cpuinfo)" >> "$OUTPUT"

# RAM Info
echo -e "\n🧠 RAM Info" >> "$OUTPUT"
echo "------------------------" >> "$OUTPUT"
sudo dmidecode --type memory | egrep -i 'Size:|Speed:|Part Number:|Manufacturer:' | grep -v 'Configured' >> "$OUTPUT"

# Disk Info
echo -e "\n💽 Disk Info" >> "$OUTPUT"
echo "------------------------" >> "$OUTPUT"
lsblk -o NAME,SIZE,TYPE,MODEL,SERIAL >> "$OUTPUT"

# Try detailed disk info for each disk
for dev in $(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}'); do
    echo -e "\nSMART Info for /dev/$dev" >> "$OUTPUT"
    sudo smartctl --info /dev/$dev >> "$OUTPUT" 2>/dev/null
done

# GPU Info
echo -e "\n🎮 GPU Info" >> "$OUTPUT"
echo "------------------------" >> "$OUTPUT"
inxi -Gxx >> "$OUTPUT"
lspci | grep -i vga >> "$OUTPUT"
echo -e "\nFull GPU Details:" >> "$OUTPUT"
sudo lshw -C display >> "$OUTPUT" 2>/dev/null

# Done
echo -e "\n✅ Done. Report saved to: $OUTPUT"
