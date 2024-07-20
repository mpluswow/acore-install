#!/bin/bash

# Function to detect current username
detect_username() {
    if [ -n "$SUDO_USER" ]; then
        USERNAME="$SUDO_USER"
    else
        USERNAME=$(whoami)
    fi

    if [ -z "$USERNAME" ]; then
        echo "Error: Unable to detect current username."
        exit 1
    fi
}

# Function to prompt for MySQL root password
prompt_mysql_root_password() {
    read -s -p "Enter MySQL root password: " db_root_password
    echo ""
}

# Function to remove MySQL databases and user
remove_mysql_entries() {
    echo "Removing MySQL databases and user..."

    mysql_config_cmd="mysql --defaults-extra-file=/tmp/mysql_config.cnf"

    cat > /tmp/mysql_config.cnf << EOF
[client]
user=root
password="${db_root_password}"
EOF

    ${mysql_config_cmd} <<EOF
DROP DATABASE IF EXISTS acore_world;
DROP DATABASE IF EXISTS acore_characters;
DROP DATABASE IF EXISTS acore_auth;
DROP USER IF EXISTS 'acore'@'localhost';
FLUSH PRIVILEGES;
EOF

    rm /tmp/mysql_config.cnf

    sleep 3
}

# Function to remove AzerothCore files and directories
remove_files() {
    echo "Removing AzerothCore files and directories..."
    rm -rf "/home/$USERNAME/AzerothCore"
    echo "AzerothCore files and directories removed."
}

# Function to remove installed packages
remove_packages() {
    echo "Removing installed packages..."
    sudo apt-get remove --purge -y git cmake make gcc g++ clang libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev
    sudo apt-get autoremove -y
    sudo apt-get clean
    echo "Installed packages removed."
}

# Main function to run all steps
main() {
    detect_username
    prompt_mysql_root_password
    remove_mysql_entries
    remove_files
    remove_packages
    echo "AzerothCore uninstallation completed successfully!"
}

# Execute main function
main

