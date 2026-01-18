# Run the script using the bash shell. 
#!/bin/bash

# STEPS
# Ensure script stops on error.
# Update package list and upgrade packages.
# Install all apt packages using packages.txt.
# Remove unecessary apt packages.
# Run manual install script (for things that require latest/specific version) (neovim).
# Set up config files - perhaps use stow.
# Miscellaneus tasks
    # Delete unecessary home drive folders.
    # Set up firewall.
    # Set up git email and username (for commit data).
    # Set up ssh keys.
    # Start ssh agent.
    # Autoremove unecessary packages.

# Stop script execution if an error occurs. 
set -e

# If updating the package database succeeds, update packages to their latest version.
sudo apt update && sudo apt upgrade -y
echo "[PROGRESS] Package database updated and all packages upgraded."

# Read all packages to install with apt into packages file, then install.
while IFS= read -r package || [[ -n "$package" ]]; do
    # If package isn't empty and doesnt start with #
    if [[ -z "$package" || "$package" =~ ^# ]]; then
        continue
    fi
    echo "Installing $package..."
    sudo apt install -y "$package"
done < ./GeneralSetup/install_packages.txt

while IFS= read -r package || [[ -n "$package" ]]; do
    # If package isn't empty and doesnt start with #
    if [[ -z "$package" || "$package" =~ ^# ]]; then
        continue
    fi
    echo "Removing $package..."
    sudo apt remove -y "$package"
done < ./GeneralSetup/remove_packages.txt

./GeneralSetup/manual_package_installs.sh

./GeneralSetup/configs_setup.sh

# Delete unecessary (empty) folders.
rm -rf ~/Desktop/ ~/Games/ ~/Pictures/ ~/Videos/ ~/Templates/ ~/Music/ ~/Public/
echo "[PROGRESS] Deleted unecessary home directory folders."

# Set up basic firewall, allowing outging traffic but blocking incoming traffic.
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw status verbose
echo "[PROGRESS] Set up basic firewall - outgoing allowed, incoming blocked."

git config --global user.email "wricks2023.16@gmail.com"
git config --global user.name "Will"

# Set up simple ssh keys.
if [[ ! -d ~/.ssh ]]; then 
    ssh-keygen -t ed25519
fi

if [ ! -d ~/Remote ]; then
	mkdir -p ~/Remote
fi
echo "[PROGRESS] SSH keys generated (if not already)."

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "[PROGRESS] Started ssh agent and added private key (need user to add public key to github)."

sudo apt autoremove
echo "[PROGRESS] Removed unecessary dependencies."

echo "[PROGRESS] To apply some changes, please log out and log into the i3 desktop environment, would you like to do this automatically? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	loginctl terminate-session "$XDG_SESSION_ID"
fi
