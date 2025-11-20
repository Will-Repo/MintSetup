# Run the script using the bash shell. 
#!/bin/bash

# Stop script execution if an error occurs. 
set -e

# If updating the package database succeeds, update packages to their latest version.
sudo apt update && sudo apt upgrade -y
echo "[PROGRESS] Package database updated and all packages upgraded."

sudo apt install i3 -y
echo "[PROGRESS] i3 desktop environment installed."

# Set up basic firewall, allowing outging traffic but blocking incoming traffic.
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw status verbose
echo "[PROGRESS} Set up basic firewall - outgoing allowed, incoming blocked."

# Install neovim, with kickstarter config.
# sudo apt install neovim -y
sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt update
sudo apt install neovim -y
git clone https://github.com/nvim-lua/kickstart.nvim ~/.config/nvim
nvim --headless "+Laxy! sync" +qa
echo "[PROGRESS] Neovim with kickstarter config set up."

# Copy my xinput config file to my home directory.
cp ./configs/.xinputrc $HOME/.xinputrc 
echo "[PROGRESS] Set up .xinputrc file."

echo "[PROGRESS] To apply some changes, please log out and log into the i3 desktop environment, would you like to do this automatically? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	loginctl terminate-session "$XDG_SESSION_ID"
fi

