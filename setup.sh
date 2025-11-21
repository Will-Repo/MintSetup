# Run the script using the bash shell. 
#!/bin/bash

# Stop script execution if an error occurs. 
set -e

# If updating the package database succeeds, update packages to their latest version.
sudo apt update && sudo apt upgrade -y
echo "[PROGRESS] Package database updated and all packages upgraded."

sudo apt install i3 -y
echo "[PROGRESS] i3 desktop environment installed."

# Delete unecessary (empty) folders.
rm -rf ~/Desktop/ ~/Games/ ~/Pictures/ ~/Videos/ ~/Templates/ ~/Music/ ~/Public/
echo "[PROGRESS] Deleted unecessary home directory folders."

# Set up basic firewall, allowing outging traffic but blocking incoming traffic.
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw status verbose
echo "[PROGRESS] Set up basic firewall - outgoing allowed, incoming blocked."

# Install neovim, with kickstarter config.
# sudo apt install neovim -y
sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt update
sudo apt install neovim -y
rm -rf ~/.config/nvim
git clone https://github.com/Will-Repo/kickstart.nvim ~/.config/nvim
nvim --headless "+Laxy! sync" +qa
echo "[PROGRESS] Neovim with kickstarter config set up."

# Copy my xinput config file to my home directory.
cp ./configs/.xinputrc $HOME/.xinputrc 
echo "[PROGRESS] Set up .xinputrc file."

# Install the JDK (JDK 25)
sudo apt install openjdk-25-jre-headless
echo "[PROGRESS] Jave JDK 25 installed and set up."

# Set up flatpak with flathub repository.
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "[PROGRESS] Flatpak set up with flathub repository."

# Create file for storing bash aliasse.
echo "alias prismmc='flatpak run org.prismlauncher.PrismLauncher'" >> ~/.bashrc
echo "alias signout='i3-msg exit'" >> ~/.bashrc
source .bashrc
echo "[PROGRESS] Set up alias's for all shell sessions."

sudo apt install ssh
echo "[PROGRESS] Ssh installed."

echo "[PROGRESS] Do you wish to install Prism Launcher? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	flatpak install -y --user flathub org.prismlauncher.PrismLauncher
fi

#echo "[PROGRESS] Do you wish to install Heroic Launcher? (Y/n)"
#read input
#if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
#	flatpak install -y --user flathub com.heroicgameslauncher.hgl
#fi

#echo "[PROGRESS] Do you wish to install Lutris? (Y/n)"
#read input
#if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
#	flatpak install -y --user flathub net.lutris.Lutris
#fi

echo "[PROGRESS] To apply some changes, please log out and log into the i3 desktop environment, would you like to do this automatically? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	loginctl terminate-session "$XDG_SESSION_ID"
fi

