#!/bin/bash
source colors.sh
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

# Function to display disclaimer and prompt user to continue
disclaimer_and_prompt() {
    cat << EOF
-----------------------------------------------------
Welcome to AzerothCore Installation Script
-----------------------------------------------------
DISCLAIMER: This script is a private project. No help will be provided.
It is created to save time when installing AzerothCore on Linux.
Please ensure MySQL is installed and you have the root credentials.
-----------------------------------------------------
EOF
    
    echo
    read -p "Do you want to continue with the installation? (yes/no): " continue_install

    if [[ "$continue_install" != "yes" ]]; then
        echo "Installation aborted."
        exit 1
    fi
}

# Function to prompt for MySQL root password
prompt_mysql_root_password() {
    echo
    read -s -p "Enter MySQL root password: " db_root_password
    echo ""
}

# Function to prompt for acore user password and export it
prompt_acore_db_password() {
    echo
    read -s -p "Create password for 'acore' MySQL user: " acore_db_password
    echo ""
    export acore_db_password
}

# Function to install required packages silently and display only on completion or failure
install_packages() {
    echo
    echo "Updating package list and installing required packages..."

    # Update package list silently
    sudo apt-get update > /dev/null

    # Install packages silently, only display on success or failure
    if sudo apt-get install -y git cmake make gcc g++ clang libmysqlclient-dev libssl-dev libbz2-dev libreadline-dev libncurses-dev libboost-all-dev > /dev/null; then
        echo
        echo "Package installation complete!"
    else
        echo "Package installation failed!"
        exit 1
    fi

    sleep 3
}

# Function to configure the MySQL database
configure_database() {
    echo
    echo "Configuring MySQL database..."

    mysql_config_cmd="mysql --defaults-extra-file=/tmp/mysql_config.cnf"

    cat > /tmp/mysql_config.cnf << EOF
[client]
user=root
password="${db_root_password}"
EOF

    ${mysql_config_cmd} <<EOF
DROP USER IF EXISTS 'acore'@'localhost';
CREATE USER 'acore'@'localhost' IDENTIFIED WITH mysql_native_password BY '${acore_db_password}';
GRANT ALL PRIVILEGES ON *.* TO 'acore'@'localhost' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS acore_world DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS acore_characters DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS acore_auth DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON acore_world.* TO 'acore'@'localhost';
GRANT ALL PRIVILEGES ON acore_characters.* TO 'acore'@'localhost';
GRANT ALL PRIVILEGES ON acore_auth.* TO 'acore'@'localhost';
FLUSH PRIVILEGES;
EOF

    rm /tmp/mysql_config.cnf

    sleep 3
}

# Function to clone AzerothCore repository
clone_azerothcore() {
    echo
    echo "Cloning AzerothCore repository..."
    echo

    if [ -d "/home/$USERNAME/AzerothCore/azerothcore-source" ]; then
        rm -rf "/home/$USERNAME/AzerothCore/azerothcore-source"
    fi

    mkdir -p "/home/$USERNAME/AzerothCore"
    git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch "/home/$USERNAME/AzerothCore/azerothcore-source"

    sleep 3
}

# Function to set up the build environment
setup_build_environment() {
    echo
    echo "Setting up build environment..."

    # Ask if the user wants to install custom modules
    read -p "Do you want to install custom modules? (yes/no): " install_modules

    if [[ "$install_modules" == "yes" ]]; then
        # Install additional modules
        "/home/$USERNAME/install-acore/data/install_modules.sh"
        if [[ $? -ne 0 ]]; then
            echo
            echo "Error: Custom module installation failed!"
            exit 1
        else
            echo
            echo "Custom modules installed successfully!"
        fi
    else
        echo
        echo "Skipping custom module installation."
    fi

    mkdir -p "/home/$USERNAME/AzerothCore/azerothcore-source/build"
    cd "/home/$USERNAME/AzerothCore/azerothcore-source/build"

    # Print current working directory for debugging
    echo
    pwd
    sleep 3
}

build_and_install() {
    echo
    echo -e "${CYAN}Building AzerothCore${NC}"
    sleep 3
    local install_prefix="/home/$USERNAME/AzerothCore/azerothcore-server/"

    # Capture cmake output to a temporary file
    cmake_output=$(mktemp)
    cmake ../ -DCMAKE_INSTALL_PREFIX="$install_prefix" -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DWITH_WARNINGS=1 -DTOOLS_BUILD=all -DSCRIPTS=static -DMODULES=static > "$cmake_output"

    # Display Apps build list
    echo -e "${YELLOW}Apps build list:${NC}"
    grep -E '\+- apps|authserver|worldserver' "$cmake_output"
    echo

    # Display Script configuration
    echo -e "${YELLOW}Script configuration:${NC}"
    grep -E '\+- worldserver|Commands|Custom|EasternKingdoms|Events|Kalimdor|Northrend|OutdoorPvP|Outland|Pet|Spells|World' "$cmake_output"
    echo

    # Display Tools build list
    echo -e "${YELLOW}Tools build list:${NC}"
    grep -E '\+- tools|dbimport|map_extractor|mmaps_generator|vmap4_assembler|vmap4_extractor' "$cmake_output"
    echo

    # Remove temporary cmake output file
    rm "$cmake_output"

    # Build AzerothCore
    local cores=$(nproc --all)
    make -j "$cores" | while IFS='' read -r line; do
        # Parse the progress percentage from the output (assuming make output format)
        progress=$(echo "$line" | grep -oE '[0-9]+%')
        if [[ ! -z $progress ]]; then
            echo -ne "\r${GREEN}Building AzerothCore: $progress${NC}"
        fi
    done
    echo
    echo -e "${GREEN}Build complete!${NC}"
    
    # Install AzerothCore
    echo -e "${CYAN}Installing AzerothCore${NC}"
    make install
    sleep 3
} 


# Function to run data and config script
run_data_and_config() {
    echo
    echo "Running data and config script..."

    # Pass acore_db_password as an argument to data_and_config.sh
    "/home/$USERNAME/install-acore/data/data_and_config.sh" "$acore_db_password"
    if [[ $? -ne 0 ]]; then
        echo "Data and config script execution failed!"
        exit 1
    else
        echo "Data and config script executed successfully!"
    fi
}

# Main function to run all steps
main() {
    detect_username
    disclaimer_and_prompt
    prompt_mysql_root_password
    prompt_acore_db_password
    install_packages
    configure_database
    clone_azerothcore
    setup_build_environment
    build_and_install
    run_data_and_config
    echo "AzerothCore installation completed successfully!"
}

# Execute main function
main

