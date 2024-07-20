#!/bin/bash
source ./data/colors.sh
log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# Function to validate MySQL connection
validate_mysql_connection() {
    log "Validating MySQL connection..."
    if ! mysql -h"$db_host" -u"$db_username" -p"$db_password" -e "QUIT" &> /dev/null; then
        error_exit "Failed to connect to MySQL with the provided credentials."
    fi
    log "MySQL connection validated successfully."
}

# Function to update the realmlist in the database
update_realmlist() {
    log "Updating realmlist in the database..."
    
    # Execute the SQL command to update the name and address
    if ! mysql -h"$db_host" -u"$db_username" -p"$db_password" acore_auth -e "UPDATE realmlist SET name='$new_name', address='$new_address' WHERE id=$realm_id;" 2>/dev/null; then
        error_exit "Failed to update realmlist."
    fi
    
    log "Realmlist updated successfully."
}

# Function to read input with a hint
read_with_hint() {
    local prompt="$1"
    local hint="$2"
    local input=""

    while true; do
        # Display prompt with hint
        echo -n "$prompt (Default: $hint): "
        
        # Read user input
        read -r input

        # Ensure the input is not empty
        if [[ -n $input ]]; then
            break
        else
            echo -e "${RED}Input cannot be empty. Please enter a valid value.${NC}"
        fi
    done

    REPLY="$input"
}

# Main function
main() {
    # Prompt user for MySQL credentials
    read -p "Enter MySQL host: " db_host
    read -p "Enter MySQL username: " db_username
    read -s -p "Enter MySQL password: " db_password
    echo
    
    # Prompt user for realm_id with a hint
    read_with_hint "Enter realm_id" "1"
    realm_id="$REPLY"
    
    # Prompt user for new_name with a hint
    read_with_hint "Enter new realm name" "AzerothCore"
    new_name="$REPLY"
    
    # Prompt user for new_address with a hint
    read_with_hint "Enter new address" "127.0.0.1"
    new_address="$REPLY"

    # Validate MySQL connection
    validate_mysql_connection
    
    # Update realmlist
    update_realmlist
    
    log "Realmlist update script completed successfully!"
}

# Execute main function
main
