#!/bin/bash

# Prompt for MySQL password (will not be shown)
read -sp "Enter MySQL password for user 'acore': " mysql_password
echo

# Prompt for user details
read -p "Enter username: " username
read -sp "Enter password: " password
echo

# Fixed parameters
g=7
N=0x894B645E89E1535BBDAD5B8B290650530801B18EBFBF5E8FAB3C82872A3E9BB7

# Generate salt (32 bytes in hexadecimal)
salt=$(openssl rand -hex 16) # Adjusted to generate 32 bytes in hexadecimal

# Calculate h1 = SHA1("USERNAME:PASSWORD")
h1=$(printf "%s:%s" "${username^^}" "${password^^}" | sha1sum | awk '{print $1}')

# Calculate h2 = SHA1(salt || h1)
h2=$(printf '%s%s' "$salt" "$h1" | xxd -r -p | sha1sum | awk '{print $1}')

# Calculate verifier = (g ^ h2) % N
verifier_decimal=$(echo "ibase=16; $(echo $h2 | tac -rs .. | tr -d '\n')" | bc)
verifier_hex=$(printf "%064x\n" "$verifier_decimal") # Pad to 64 characters

# Convert verifier_hex to binary
verifier_binary=$(echo "$verifier_hex" | xxd -r -p)

# SQL query to insert into account table in acore_auth database
sql_query="INSERT INTO acore_auth.account (username, salt, verifier) VALUES ('$username', 0x$salt, 0x$verifier_binary);"

# Execute the SQL query using MySQL command-line tool
echo "$sql_query" | mysql -u acore -p"$mysql_password" acore_auth

echo "User '$username' created successfully."
