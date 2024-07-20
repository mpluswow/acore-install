#!/bin/bash

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

# Main function
main() {
    # Prompt user for MySQL credentials
    read -p "Enter MySQL host: " db_host
    read -p "Enter MySQL username: " db_username
    read -s -p "Enter MySQL password: " db_password
    echo
    
    # Prompt user for realm_id
    read -p "Enter realm_id: " realm_id
    
    # Prompt user for new_name
    read -p "Enter new realm name: " new_name
    
    # Prompt user for new_address
    read -p "Enter new address: " new_address

    # Validate MySQL connection
    validate_mysql_connection
    
    # Update realmlist
    update_realmlist
    
    log "Realmlist update script completed successfully!"
}

# Execute main function
main
