#!/bin/bash

# Function to display progress messages
progress_message() {
    echo "[INFO] $1"
}

# Function to display error messages
error_message() {
    echo "[ERROR] $1"
}

# Function to stop and disable a systemd service
stop_and_disable_service() {
    service_name="$1"
    progress_message "Stopping and disabling $service_name service..."

    # Stop the service
    sudo systemctl stop "$service_name"

    # Disable the service
    sudo systemctl disable "$service_name"

    # Check if service is still active
    if systemctl is-active --quiet "$service_name"; then
        error_message "Failed to stop $service_name service."
    else
        progress_message "$service_name service stopped and disabled successfully."
    fi
}

# Function to remove systemd service file
remove_service_file() {
    service_name="$1"
    progress_message "Removing $service_name systemd service file..."

    # Remove service file
    sudo rm -f "/etc/systemd/system/$service_name.service"

    # Check if service file is removed
    if [ -f "/etc/systemd/system/$service_name.service" ]; then
        error_message "Failed to remove $service_name service file."
    else
        progress_message "$service_name service file removed successfully."
    fi
}

# Function to uninstall authserver and worldserver services
uninstall_services() {
    stop_and_disable_service "authserver"
    stop_and_disable_service "worldserver"
    
    remove_service_file "authserver"
    remove_service_file "worldserver"

    # Reload systemd after modifications
    sudo systemctl daemon-reload

    progress_message "Uninstallation completed."
}

# Main function
main() {
    uninstall_services
}

# Execute main function
main

