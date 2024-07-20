acore() {
    USER=$(whoami)
    BASE_DIR="/home/$USER/AzerothCore/azerothcore-server"

    if [ -z "$1" ]; then
        echo "Usage: acore {dir|status|help} [suboption]"
        return 1
    fi

    case "$1" in
        dir)
            if [ -z "$2" ]; then
                echo "Usage: acore dir {bin|src}"
                return 1
            fi
            case "$2" in
                bin)
                    DIR="$BASE_DIR/bin"
                    if [ -d "$DIR" ]; then
                        echo "Navigating to the Server Data directory..."
                        cd "$DIR"
                    else
                        echo "Directory $DIR does not exist."
                    fi
                    ;;
                src)
                    DIR="$BASE_DIR/etc"
                    if [ -d "$DIR" ]; then
                        echo "Navigating to the Server Config directory..."
                        cd "$DIR"
                    else
                        echo "Directory $DIR does not exist."
                    fi
                    ;;
                *)
                    echo "Invalid suboption for dir. Usage: acore dir {bin|src}"
                    ;;
            esac
            ;;
        status)
            if [ -z "$2" ]; then
                echo "Usage: acore status {world|auth}"
                return 1
            fi
            case "$2" in
                world)
                    echo "Checking the status of the world server..."
                    systemctl status worldserver.service
                    ;;
                auth)
                    echo "Checking the status of the auth server..."
                    systemctl status authserver.service
                    ;;
                *)
                    echo "Invalid suboption for status. Usage: acore status {world|auth}"
                    ;;
            esac
            ;;
        help)
            echo "Usage: acore {dir|status|help} [suboption]"
            echo
            echo "Commands:"
            echo "  dir {bin|src}    - Navigate to the specified directory:"
            echo "    bin            - Navigate to /home/$USER/AzerothCore/azerothcore-server/bin"
            echo "    src            - Navigate to /home/$USER/AzerothCore/azerothcore-server/etc"
            echo
            echo "  status {world|auth} - Check the status of the specified service:"
            echo "    world          - Check the status of the worldserver.service"
            echo "    auth           - Check the status of the authserver.service"
            echo
            echo "  help             - Display this help message"
            ;;
        *)
            echo "Invalid command. Usage: acore {dir|status|help} [suboption]"
            ;;
    esac
}
