#!/bin/bash

# Function to display progress messages
progress_message() {
    echo "[INFO] $1"
}

# Function to display error messages
error_message() {
    echo "[ERROR] $1" >&2
}

# Function to check if a directory exists and is accessible
check_directory() {
    if [[ ! -d $1 ]]; then
        error_message "Directory $1 does not exist."
        exit 1
    elif [[ ! -r $1 || ! -x $1 ]]; then
        error_message "Directory $1 is not accessible."
        exit 1
    fi
}

# Function to check if a file exists and is executable
check_executable() {
    if [[ ! -x $1 ]]; then
        error_message "File $1 does not exist or is not executable."
        exit 1
    fi
}

# Function to get the original user
get_user_home() {
    if [[ -n $SUDO_USER ]]; then
        echo "/home/$SUDO_USER"
    else
        echo "$HOME"
    fi
}

# Function to install authserver systemd service
install_authserver_service() {
    progress_message "Installing authserver systemd service..."
    USER_HOME=$(get_user_home)
    AUTH_WORK_DIR="$USER_HOME/AzerothCore/azerothcore-server/bin"
    AUTH_EXEC="$AUTH_WORK_DIR/authserver"

    # Check directories and executables
    check_directory "$AUTH_WORK_DIR"
    check_executable "$AUTH_EXEC"

    AUTH_SERVICE_PATH="/etc/systemd/system/authserver.service"
    sudo tee $AUTH_SERVICE_PATH > /dev/null <<EOF
[Unit]
Description=AzerothCore Authentication Server
After=network.target

[Service]
User=$(whoami)
WorkingDirectory=$AUTH_WORK_DIR
ExecStart=$AUTH_EXEC
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable authserver
    sudo systemctl start authserver

    # Check service status
    if systemctl is-active --quiet authserver; then
        progress_message "authserver service installed successfully."
    else
        error_message "Failed to install authserver service. Check logs for details."
        sudo systemctl status authserver
    fi
}

# Function to install worldserver systemd service
install_worldserver_service() {
    progress_message "Installing worldserver systemd service..."
    USER_HOME=$(get_user_home)
    WORLD_WORK_DIR="$USER_HOME/AzerothCore/azerothcore-server/bin"
    WORLD_EXEC="$WORLD_WORK_DIR/worldserver"

    # Check directories and executables
    check_directory "$WORLD_WORK_DIR"
    check_executable "$WORLD_EXEC"

    WORLD_SERVICE_PATH="/etc/systemd/system/worldserver.service"
    sudo tee $WORLD_SERVICE_PATH > /dev/null <<EOF
[Unit]
Description=AzerothCore World Server
After=authserver.service

[Service]
User=$(whoami)
WorkingDirectory=$WORLD_WORK_DIR
ExecStart=$WORLD_EXEC
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable worldserver
    sudo systemctl start worldserver

    # Check service status
    if systemctl is-active --quiet worldserver; then
        progress_message "worldserver service installed successfully."
    else
        error_message "Failed to install worldserver service. Check logs for details."
        sudo systemctl status worldserver
    fi
}

# Main function to install both services
main() {
    install_authserver_service
    install_worldserver_service
}

# Execute main function
main

