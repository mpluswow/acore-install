#!/bin/bash

# Ensure acore_db_password is passed as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <acore_db_password>"
    exit 1
fi

acore_db_password="$1"

log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# Function to detect current username
detect_username() {
    if [ -n "$SUDO_USER" ]; then
        USERNAME="$SUDO_USER"
    else
        USERNAME=$(whoami)
    fi

    if [ -z "$USERNAME" ]; then
        error_exit "Unable to detect current username."
    fi
    log "Detected username: $USERNAME"
}

# Function to set up data folders and download necessary files
setup_data_folders() {
    log "Setting up data folders..."
    cd "/home/$USERNAME/AzerothCore/azerothcore-server/bin/" || error_exit "Failed to change directory."
    
    mkdir -p logs data tools || error_exit "Failed to create directories."
    mv dbimport map_extractor mmaps_generator vmap4_assembler vmap4_extractor ./tools/ || error_exit "Failed to move tools."

    wget https://github.com/wowgaming/client-data/releases/download/v16/data.zip || error_exit "Failed to download data.zip."
    unzip data.zip -d data || error_exit "Failed to unzip data.zip."
    rm data.zip || error_exit "Failed to remove data.zip."

    sleep 3
    log "Data folders set up successfully."
}

# Function to configure authserver.conf
configure_authserver_conf() {
    log "Configuring authserver.conf..."
    cd "/home/$USERNAME/AzerothCore/azerothcore-server/etc/" || error_exit "Failed to change directory."
    
    cp authserver.conf.dist authserver.conf || error_exit "Failed to copy authserver.conf.dist."
    sed -i "s/LoginDatabaseInfo = \"127.0.0.1;3306;acore;acore;acore_auth\"/LoginDatabaseInfo = \"127.0.0.1;3306;acore;${acore_db_password};acore_auth\"/" authserver.conf || error_exit "Failed to update authserver.conf."
    
    log "authserver.conf configured successfully."
}

# Function to configure worldserver.conf
configure_worldserver_conf() {
    log "Configuring worldserver.conf..."
    cd "/home/$USERNAME/AzerothCore/azerothcore-server/etc/" || error_exit "Failed to change directory."
    
    cp worldserver.conf.dist worldserver.conf || error_exit "Failed to copy worldserver.conf.dist."

    log "Before update: $(grep 'LoginDatabaseInfo' worldserver.conf)"
    sed -i "s|LoginDatabaseInfo[[:space:]]*=[[:space:]]*\"127.0.0.1;3306;acore;acore;acore_auth\"|LoginDatabaseInfo = \"127.0.0.1;3306;acore;${acore_db_password};acore_auth\"|" worldserver.conf || error_exit "Failed to update LoginDatabaseInfo in worldserver.conf."
    log "After update: $(grep 'LoginDatabaseInfo' worldserver.conf)"

    log "Before update: $(grep 'WorldDatabaseInfo' worldserver.conf)"
    sed -i "s|WorldDatabaseInfo[[:space:]]*=[[:space:]]*\"127.0.0.1;3306;acore;acore;acore_world\"|WorldDatabaseInfo = \"127.0.0.1;3306;acore;${acore_db_password};acore_world\"|" worldserver.conf || error_exit "Failed to update WorldDatabaseInfo in worldserver.conf."
    log "After update: $(grep 'WorldDatabaseInfo' worldserver.conf)"

    log "Before update: $(grep 'CharacterDatabaseInfo' worldserver.conf)"
    sed -i "s|CharacterDatabaseInfo[[:space:]]*=[[:space:]]*\"127.0.0.1;3306;acore;acore;acore_characters\"|CharacterDatabaseInfo = \"127.0.0.1;3306;acore;${acore_db_password};acore_characters\"|" worldserver.conf || error_exit "Failed to update CharacterDatabaseInfo in worldserver.conf."
    log "After update: $(grep 'CharacterDatabaseInfo' worldserver.conf)"

    sed -i "s|DataDir[[:space:]]*=[[:space:]]*\".\"|DataDir = \"./data/\"|" worldserver.conf || error_exit "Failed to update DataDir in worldserver.conf."
    sed -i "s|LogsDir[[:space:]]*=[[:space:]]*\"\"|LogsDir = \"./logs/\"|" worldserver.conf || error_exit "Failed to update LogsDir in worldserver.conf."

    # Add the new configuration change here
    sed -i "s|Ra.Enable[[:space:]]*=[[:space:]]*0|Ra.Enable = 1|" worldserver.conf || error_exit "Failed to update Ra.Enable in worldserver.conf."

    log "worldserver.conf configured successfully."
}

# Main function to run all post-install steps
post_install_main() {
    detect_username
    setup_data_folders
    configure_authserver_conf
    configure_worldserver_conf
    log "Post-installation steps completed successfully!"
}

# Execute post-install main function
post_install_main

