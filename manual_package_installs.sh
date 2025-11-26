# Install neovim, with kickstarter config.
# sudo apt install neovim -y
sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt update
#sudo apt install neovim -y
#flatpak install --assumeyes flathub io.neovim.nvim
#sudo apt install snap -y
#sudo npm install snapd -y
#sudo snap install neovim --classic -y
#git clone https://github.com/neovim/neovim.git
#cd neovim
#git checkout stable
#make CMAKE_BUILD_TYPE=Release
#sudo make install
#cd ..
#rm -rf neovim
sudo apt install neovim -y
rm -rf ~/.config/nvim
git clone https://github.com/Will-Repo/kickstart.nvim ~/.config/nvim
rm -rf ~/.local/share/nvim/site/pack/packer/start
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
npm install tree-sitter-cli
nvim --headless "+Laxy! sync" +qa
echo "[PROGRESS] Neovim with kickstarter config set up."

wget https://github.com/Kitware/CMake/releases/download/v4.1.1/cmake-4.1.1-Linux-x86_64.sh
chmod +x cmake-4.1.1-Linux-x86_64.sh
sudo ./cmake-4.1.1-Linux-x86_64.sh --prefix=/usr/local --skip-license
rm ./cmake-4.1.1-Linux-x86_64.sh
echo "[PROGRESS] Installed cmake."

# Set up flatpak with flathub repository.
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "[PROGRESS] Flatpak set up with flathub repository."

sudo extrepo enable librewolf
sudo apt update && sudo apt install librewolf -y
echo "[PROGESS] Librewolf installed."

sudo flatpak install flathub com.discordapp.Discord -y
echo "[PROGRESS] Installed discord."

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

# Afnom - web hacking
# ZAP - web proxy/
flatpak install flathub org.zaproxy.ZAP

wget http://www.caesum.com/handbook/Stegsolve.jar -O stegsolve.jar
chmod +x stegsolve.jar
sudo mv ./stegsolve.jar /usr/local/bin/ 

wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.4.2_build/ghidra_11.4.2_PUBLIC_20250826.zip
unzip ghidra_11.4.2_PUBLIC_20250826.zip
sudo mv ghidra_11.4.2_PUBLIC /opt/ghidra
rm ghidra_11.4.2_PUBLIC_20250826.zip
