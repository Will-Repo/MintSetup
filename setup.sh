# Run the script using the bash shell. 
#!/bin/bash

# Stop script execution if an error occurs. 
set -e

# If updating the package database succeeds, update packages to their latest version.
sudo apt update && sudo apt upgrade -y
echo "[PROGRESS] Package database updated and all packages upgraded."

sudo apt install i3 -y
echo "[PROGRESS] i3 desktop environment installed."

# Set up i3 configuration.
sudo apt install polybar -y
echo "[PROGRESS] Installed polybar for i3 configuration."

if [ ! -d ~/.config/polybar ]; then
  mkdir ~/.config/polybar
fi
cp -f ./configs/polybar ~/.config/polybar/config.ini
echo "[PROGRESS] Set up polybar config."

cp -f ./configs/i3 ~/.config/i3/config
echo "[PROGESS] Set up i3 config."

#sudo apt install sway -y
#echo "[PROGRESS] sway desktop environment installed."

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
cp -f ./configs/.xinputrc ~/.xinputrc 
echo "[PROGRESS] Set up .xinputrc file."

# Install the JDK (JDK 25)
sudo apt install openjdk-25-jre-headless -y
echo "[PROGRESS] Jave JDK 25 installed and set up."

wget https://github.com/Kitware/CMake/releases/download/v4.1.1/cmake-4.1.1-Linux-x86_64.sh
chmod +x cmake-4.1.1-Linux-x86_64.sh
sudo ./cmake-4.1.1-Linux-x86_64.sh --prefix=/usr/local --skip-license
rm ./cmake-4.1.1-Linux-x86_64.sh
echo "[PROGRESS] Installed cmake."

sudo apt install libwayland-dev libxkbcommon-dev xorg-dev
sudo apt install python3-jinja2
echo "[PROGRESS] Installed glfw3 and opengl build dependencies."

# Set up flatpak with flathub repository.
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "[PROGRESS] Flatpak set up with flathub repository."

# Overwrite bashrc with my custom one, then set it up for this shell session.
cp -f ./configs/.bashrc ~/.bashrc
cp -f ./configs/.bash_aliases ~/.bash_aliases
source ~/.bashrc ~/.bash_aliases
echo "[PROGRESS] Set up .bashrc and .bash_aliases - aliases set up."

sudo apt install ssh -y
echo "[PROGRESS] Ssh installed."

xset s off 
echo "[PROGRESS] Disabled automatic screen dimming."

sudo apt remove firefox -y
echo "[PROGRESS] Removed firefox."

sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo apt update && sudo apt install librewolf -y
echo "[PROGESS] Librewolf installed."

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

if ! command -v rclone &> /dev/null; then
	sudo -v ; curl https://rclone.org/install.sh | sudo bash
	echo "[PROGRESS] Installed rclone."
fi

if [ ! -d ~/Remote ]; then
	mkdir -p ~/Remote
fi

echo "[PROGRESS] Do you wish to set up a google drive folder using rclone (IMPORTANT: name the drive 'gdrive')?"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	rclone config
	mkdir -p ~/Remote/gdrive
	echo "[PROGRESS] The latest drive (stored in ~/Remote/gdrive) can be accessed by running the gdrive command (alias), and will continue to update until the mounting is ended by stopgdrive."
fi

#echo "[PROGRESS] Do you wish to set up a google photos folder using rclone (IMPORTANT: name the drive 'gphotos')?"
#read input
#if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
#	rclone config
#	mkdir -p ~/Remote/gphotos
#	echo "[PROGRESS] The latest drive (stored in ~/Remote/gphotos) can be accessed by running the gphotos command (alias), and will continue to update until the mounting is ended by stopgphotos."
#fi

#echo "[PROGRESS] Do you wish to set up a(n) OneDrive folder for university using rclone (IMPORTANT: name the drive 'oduni')?"
#read input
#if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
#	rclone config
#	mkdir -p ~/Remote/oduni
#	echo "[PROGRESS] The latest drive (stored in ~/Remote/oduni) can be accessed by running the oduni command (alias), and will continue to update until the mounting is ended by stopoduni."
#fi

echo "[PROGRESS] Do you wish to set up a(n) OneDrive folder for a google account using rclone (IMPORTANT: name the drive 'odgoogle')?"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	rclone config
	mkdir -p ~/Remote/odgoogle
	echo "[PROGRESS] The latest drive (stored in ~/Remote/odgoogle) can be accessed by running the odgoogle command (alias), and will continue to update until the mounting is ended by stopodgoogle."
fi

echo "[PROGRESS] To apply some changes, please log out and log into the i3 desktop environment, would you like to do this automatically? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	loginctl terminate-session "$XDG_SESSION_ID"
fi

sudo apt autoremove
echo "[PROGRESS] Removed unecessary dependencies."
