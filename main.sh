#!/bin/sh
# ====================================================
# =                                                  =
# =                Author: chris hijman              =
# =                Version: 0.6                      =
# =                                                  =
# ====================================================

# BACKUP_DIR="/mnt/backup/manual" # locatie van de backups
# TARGET_DIR="/srv/www/wordpress" # locatie van de wordpress directory

AUTHOR="chris hijman"
VERSION="0.6"

clear

menu() {
    echo "========================="
    echo "  Maintenance Script"
    echo "  Author: $AUTHOR"
    echo "  Version: $VERSION"
    echo "========================="
    echo "options:"
    echo "========================="
    echo "1. update"
    echo "2. backup"
    echo "3. info"
    echo "4. User options"
    echo "0. exit"
    echo "========================="
    read -p "Select an option: " option
    case $option in
        1)
            update
            ;;
        2)
            backup_menu
            ;;
        3)
            info
            ;;
        4)
            user_options
            ;;
        0)
            clear
            echo "Bye!"
            exit 0
            ;;
        *)
            echo "Invalid option"
            menu
            ;;
    esac
}

update() {
    clear
    upgradable_packages=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")
    apt update && apt upgrade -y
    clear
    echo "geupgrade pakketten:"
    echo "$upgradable_packages"
    menu
}

backup_menu () {
    clear
    echo "========================="
    echo "  Backup Options"
    echo "========================="
    echo "1. Backup wordpress"
    echo "2. Restore wordpress"
    echo "3. Show backups"
    echo "0. Go back"
    echo "========================="
    read -p "Select an option: " option
    case $option in
        1)
            backup
            ;;
        2)
            restore
            ;;
        0)
            clear
            menu
            ;;
        *)
            echo "Invalid option"
            backup_menu
            ;;
    esac
}

info() {
    clear
    page=1
    while true; do
        case $page in
            1)
                echo "Kernel version: $(uname -r)"
                echo "OS version: $(lsb_release -d | awk -F"\t" '{print $2}')"
                echo "Disk usage:"
                df -h
                ;;
            2)
                echo "Memory usage:"
                free -h
                echo "CPU info:"
                lscpu | grep "Model name"
                ;;
            3)
                echo "Network interfaces:"
                ip addr
                echo "Uptime:"
                uptime
                ;;
            4)
                echo "Last 10 logins:"
                last -n 10
                echo "Last 10 system logs:"
                tail -n 10 /var/log/syslog
                ;;
            *)
                echo "Invalid page"
                ;;
        esac
        echo "========================="
        read -p "Press N for next page, P for previous page, or M to return to menu: " key
        case $key in
            [Nn])
                page=$((page + 1))
                if [ $page -gt 4 ]; then
                    page=1
                fi
                ;;
            [Pp])
                page=$((page - 1))
                if [ $page -lt 1 ]; then
                    page=4
                fi
                ;;
            [Mm])
                clear
                menu
                break
                ;;
            *)
                echo "Invalid input"
                ;;
        esac
        clear
    done
}

user_options() {
    clear
    echo "========================="
    echo "  User Options"
    echo "========================="
    echo "1. Add user"
    echo "2. Delete user"
    echo "3. Change password"
    echo "4. Show users"
    echo "0. Go back"
    echo "========================="
    read -p "Select an option: " option
    case $option in
        1)
            add_user
            ;;
        2)
            delete_user
            ;;
        3)
            change_password
            ;;
        4)
            show_users
            ;;
        0)
            clear
            menu
            ;;
        *)
            echo "Invalid option"
            user_options
            ;;
    esac
}

add_user() {
    clear
    read -p "Enter username: " username
    read -p "Enter password: " password
    useradd -m -s /bin/bash "$username"
    echo "$username:$password" | chpasswd
    echo "User $username added."
    user_options
}

delete_user() {
    clear
    read -p "Enter username to delete: " username
    userdel -r "$username"
    echo "User $username deleted."
    user_options
}

change_password() {
    clear
    read -p "Enter username to change password: " username
    read -p "Enter new password: " password
    echo "$username:$password" | chpasswd
    echo "Password for user $username changed."
    user_options
}

show_users() {
    clear
    echo "========================="
    echo "  User List"
    echo "========================="
    cut -d: -f1 /etc/passwd | sort
    echo "========================="
    read -p "Press any key to go back..." key
    user_options
}

backup() {
    clear
    timestamp=$(date +"%d-%m-%Y_%H-%M-%S")
    tar -cf - /srv/www/wordpress | pv -s $(du -sb /srv/www/wordpress | awk '{print $1}') | gzip > /mnt/backup/manual/backup_$timestamp.tar.gz # hier wordt de backup gemaakt
    echo "Backup complete..."
    backup_menu
}

restore() {
    clear
    echo "=========================="
    echo "Available backups:"
    echo "=========================="
    echo "Backup files in /mnt/backup/manual:"
    ls -l /mnt/backup/manual/backup_*.tar.gz 2>/dev/null || echo "No backups found"
    echo "=========================="
    read -p "Enter the full path of the backup file to restore, or type 0 to return to the backup menu: " backup_file
    if [ "$backup_file" = "0" ]; then
        clear
        backup_menu
    elif [ -f "$backup_file" ]; then
        echo "Restoring from $backup_file..."
        rm -rf /srv/www/wordpress
        mkdir -p /srv/www/wordpress
        tar --strip-components=1 -xzvf "$backup_file" -C /srv
        chown -R www-data:www-data /srv/www/wordpress
        echo "Restore complete..."
    else
        clear
        echo "Backup file not found. Ensure the file path is correct and try again."
        restore
    fi 
    backup_menu
}

menu