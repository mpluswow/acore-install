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

# Function to prompt for module installation
prompt_and_clone_modules() {
    echo "Cloning additional modules..."

    MODULES_DIR="/home/$USERNAME/AzerothCore/azerothcore-source/modules"

    mkdir -p "$MODULES_DIR"
    cd "$MODULES_DIR" || exit 1

    declare -A modules=(
    ["mod-progression-system"]="https://github.com/azerothcore/mod-progression-system.git"
    ["mod-eluna"]="https://github.com/azerothcore/mod-eluna.git"
    ["mod-1v1-arena"]="https://github.com/azerothcore/mod-1v1-arena.git"
    ["mod-account-mounts"]="https://github.com/azerothcore/mod-account-mounts"
    ["mod-transmog"]="https://github.com/azerothcore/mod-transmog.git"
    ["mod-weapon-visual"]="https://github.com/azerothcore/mod-weapon-visual.git"
)

    for module in "${!modules[@]}"; do
        while true; do
            read -r -p "Do you want to install $module? (yes/no): " install
            case $install in
                yes)
                    if [ ! -d "$MODULES_DIR/$module" ]; then
                        git clone "${modules[$module]}" "$MODULES_DIR/$module"
                        echo "$module cloned successfully!"
                    else
                        echo "$module already exists. Skipping clone."
                    fi
                    break ;;
                no)
                    echo "$module not installed."
                    break ;;
                *)
                    echo "Please answer yes or no."
                    ;;
            esac
        done
    done
}

# Main function to run all steps
main() {
    detect_username
    prompt_and_clone_modules
}

# Execute main function
main

