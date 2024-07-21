#!/bin/bash

# Function to check if the command succeeded
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Update package lists
echo "Updating package lists..."
sudo apt-get update
check_command "Failed to update package lists"

# Install ddclient
echo "Installing ddclient..."
sudo apt-get install -y ddclient
check_command "Failed to install ddclient"

# Prompt user for Dynu credentials and hostname
echo "Please enter your Dynu credentials and hostname."
read -p "Dynu Email (login): " DYNU_EMAIL
read -sp "Dynu Password: " DYNU_PASSWORD
echo
read -p "Dynu Hostname: " DYNU_HOSTNAME

# Create ddclient configuration
echo "Creating ddclient configuration file..."
sudo tee /etc/ddclient.conf > /dev/null <<EOL
protocol=dyndns2
use=web, web=ipinfo.io/ip
server=api.dynu.com
login=${DYNU_EMAIL}
password='${DYNU_PASSWORD}'
${DYNU_HOSTNAME}
EOL
check_command "Failed to create ddclient configuration file"

# Configure ddclient to use the default settings
sudo sed -i 's/^# daemon=.*/daemon=300/' /etc/default/ddclient
sudo sed -i 's/^# mail=/mail=/etc/cron.d/ddclient' /etc/default/ddclient

# Start and enable ddclient service
echo "Starting and enabling ddclient service..."
sudo systemctl restart ddclient
check_command "Failed to restart ddclient service"
sudo systemctl enable ddclient
check_command "Failed to enable ddclient service"

echo "ddclient setup complete. Your configuration is now active."
