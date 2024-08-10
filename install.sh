#!/bin/bash

# Check if the script is being run as root
if [ "$(whoami)" != "root" ]; then
    echo "You must be root to execute this script."
    exit 1
fi

# Variables
DIRNAME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLATION_DIR="/opt"
INSTALLATION_PROJECT="$INSTALLATION_DIR/OSCP"
EXECUTABLE_DIR="$INSTALLATION_PROJECT/notas.py"

# Colors for output
RESTORE='\033[0m'
RED='\033[00;31m'
GREEN='\033[00;32m'
LBLUE='\033[01;34m'

# Clear the screen
clear

# Logo
echo -e "$GREEN░▀█▀░█▀█░█▀▀░▀█▀░█▀█░█░░░█▀█░█▀▀░▀█▀░█▀█░█▀█░░░█▀█░█▀▀░█▀▀░█▀█$RESTORE"
echo -e "$GREEN░░█░░█░█░▀▀█░░█░░█▀█░█░░░█▀█░█░░░░█░░█░█░█░█░░░█░█░▀▀█░█░░░█▀▀$RESTORE"
echo -e "$GREEN░▀▀▀░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░░░▀▀▀░▀▀▀░▀▀▀░▀░░$RESTORE"

echo -e "\n$GREEN[+]$RESTORE Installing application in" $INSTALLATION_DIR 

# Check Python dependencies
echo -e "$GREEN[+]$RESTORE Checking Python dependencies"
if ! python -c "import termcolor" 2> /dev/null; then
    echo -e "$LBLUE[!]$RESTORE Installing termcolor library"
    pip install termcolor
fi

if ! python -c "import git" 2> /dev/null; then
    echo -e "$LBLUE[!]$RESTORE Installing gitpython library"
    pip install gitpython
fi

echo -e "$GREEN[+]$RESTORE All necessary Python libraries installed"

# Check if the installation directory exists
if [ ! -d "$INSTALLATION_PROJECT" ]; then
    mkdir -p "$INSTALLATION_PROJECT"
    echo -e "$GREEN[+]$RESTORE Directory $INSTALLATION_PROJECT successfully created"

    # Copy files and directories to the installation directory
    cp -r "$DIRNAME"/* "$INSTALLATION_PROJECT"
    echo -e "$GREEN[+]$RESTORE Files successfully copied to $INSTALLATION_PROJECT"
else
    echo -e "$RED[-]$RESTORE The directory $INSTALLATION_PROJECT already exists"
    exit 1
fi

# Create an alias to run the script from anywhere in the terminal
echo -e "$GREEN[+]$RESTORE Creating an alias for the application"
ALIASES_FILE=""

if [ -f ~/.aliases ]; then
    ALIASES_FILE=~/.aliases
elif [ -f ~/.bash_aliases ]; then
    ALIASES_FILE=~/.bash_aliases
elif [ -f ~/.bashrc ]; then
    ALIASES_FILE=~/.bashrc
fi

if [ -n "$ALIASES_FILE" ]; then
    if ! grep -q "notas.py" "$ALIASES_FILE"; then
        echo 'alias notas="python '"$EXECUTABLE_DIR"'"' >> "$ALIASES_FILE"
        echo -e "$GREEN[+]$RESTORE Alias added to $ALIASES_FILE"
    else
        echo -e "$LBLUE[!]$RESTORE Alias already exists in $ALIASES_FILE"
    fi
fi

# Change permissions if the program will be used by a non-root user
read -e -p "Will you use the application as a non-privileged user? [y/n]: " opt
if [ "$opt" == "y" ]; then
    read -e -p "Enter the username: " username
    if id -u "$username" > /dev/null 2>&1; then
        chown -R "$username:$username" "$INSTALLATION_PROJECT"
        echo -e "$GREEN[+]$RESTORE Permissions successfully changed"
    else
        echo -e "$RED[-]$RESTORE The specified user does not exist."
    fi
fi

echo -e "\n$GREEN[*]$RESTORE Installation completed in $INSTALLATION_PROJECT"
echo -e "\n$LBLUE[!]$RESTORE To run the application, open a new terminal session and type 'notas'\n"
