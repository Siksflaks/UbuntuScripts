#!/bin/sh

# ====================================================
# =                                                  =
# =                Author: Chris Hijman              =
# =                Version: 0.3                      =
# =                                                  =
# ====================================================

clear # scherm leegmaken

AUTHOR="chris hijman" # auteur van het script
VERSION="0.3" # versie van het script


menu() { # menu functie, hierin worden de opties weergegeven
    echo "========================="
    echo "  Maintenance Script"
    echo "  Author: $AUTHOR"
    echo "  Version: $VERSION"
    echo "========================="
    echo "options:"
    echo "========================="
    echo "1. update"
    echo "2. backup"
    echo "0. exit"
    echo "========================="
    read -p "Select an option: " option # hier wordt gevraagt welke optie je kiest
    case $option in # hier worden de opties verwerkt
        1)
            update
            ;;
        2)
            backup_menu
            ;;
        3)
            restore
            ;;
        0)
            clear
            echo "Bye!"
            exit 0
            ;;
        *)
            echo "Invalid option" # als je een ongeldige optie kiest krijg je een foutmelding
            menu
            ;;
    esac
}

update() { # update functie, dit haalt updates op en upgrade ook meteen
    clear
    apt update && apt upgrade -y
    clear
    menu
}

backup_menu () { # backup menu functie, hierin worden de opties weergegeven voor backups
    clear
    echo "========================="
    echo "  Backup Options"
    echo "========================="
    echo "1. Backup wordpress"
    echo "2. Restore wordpress"
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

backup() { # backup functie, dit maakt een backup van de wordpress directory
    clear
    timestamp=$(date +"%d-%m-%Y_%H-%M-%S") # timestamp voor de backup
    tar -cf - /path/to/target | pv -s $(du -sb /path/to/target | awk '{print $1}') | gzip > /path/to/storage/backup_$timestamp.tar.gz # hier wordt de backup gemaakt
    echo "Backup complete..."
    backup_menu
}


restore() { # restore functie, dit herstelt de backup
    clear
    echo "=========================="
    echo "Available backups:"
    echo "=========================="
    ls -l /mnt/backup/manual/backup_*.tar.gz
    echo "=========================="
    read -p "Enter the full path of the backup file to restore or select 0 to go back: " backup_file # hier wordt gevraagt welke backup je wilt herstellen
    if [ "$backup_file" = "0" ]; then # als je 0 kiest ga je terug naar het menu
        clear
        backup_menu
    elif [ -f "$backup_file" ]; then # als het bestand bestaat ga je verder
        echo "Restoring from $backup_file..."
        # Remove the existing WordPress directory
        rm -rf /path/to/target
        # Recreate the WordPress directory
        mkdir -p /path/to/target
        # Extract the backup into the WordPress directory
        tar --strip-components=1 -xzvf "$backup_file" -C /path/to/target # Test to see if it replaces the backup correctly
        # Set ownership to www-data
        # chown -R www-data:www-data /srv/www/wordpress
        echo "Restore complete..."
    else # als het bestand niet bestaat krijg je een foutmelding
        echo "Backup file not found. Please try again."
        restore
    fi
    backup_menu
}

menu # start het menu
