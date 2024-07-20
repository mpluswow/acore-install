# AzerothCore Install Script

## Introduction

If you've ever found yourself frustrated with the manual process of setting up and updating your AzerothCore server, this script is here to make your life easier. Designed with simplicity in mind, this script helps you effortlessly set up and configure AzerothCore.

## What Does This Script Do?

Think of this script as your easiest way to install AzerothCore. It does the following:

- **Installs AzerothCore**: Quickly and easily get AzerothCore and its modules installed.
- **Configures Your Realm**: Set up game realm settings such as Realm ID, Name, and Address.
- **Manages Services**: Easily install or remove AzerothCore as a service on your system.
- **Uninstalls AzerothCore**: Completely remove AzerothCore if you decide it’s time for a change.

## What You Need

- **sudo Access**: This script requires elevated permissions to make system changes, so you'll need to run it with `sudo`.
- **Linux Server**: Designed to run in a Bash shell, which is common on most Linux systems.

## How to Use the Script

1. **Make the Script Executable**  
   Ensure the script is executable. Open your terminal and type:

   ```bash
   chmod +x acore-menu.sh
 
   sudo ./acore-menu.sh




## 🚀 Key Features

### Seamless MySQL Configuration
The script takes care of configuring all the essential databases and user privileges.

### Automated Package Installation
The script updates your package list and installs all the required software packages in one go, 
ensuring that your server environment is prepared.

### Repository Setup
Clones the latest AzerothCore source code directly from GitHub, ensuring you have the freshest version of the software. 
[WARNING] It removes any old versions to avoid conflicts.

### Customization 
Want to enhance your server with custom modules? The script gives you the option to install additional modules from GitHub.


### Hassle-Free Data and Configuration
Once the core installation is complete, the script runs additional setup tasks to get your server ready to go, 
including GAME DATA download, worldserver and authserver configuration.







