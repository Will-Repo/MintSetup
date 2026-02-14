# Can't do this atomatically as it requires manual input in windows.
# Install regular and MCSR instances
nohup /opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage &
/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -I "https://github.com/Fabulously-Optimized/fabulously-optimized/releases/download/v12.0.2/Fabulously.Optimized-12.0.2.zip"
/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -I "https://redlime.github.io/MCSRMods/modpacks/v4/MCSRRanked-Linux-1.16.1-Pro.mrpack"

# Download and set up rsg minecraft speedrunning instance.
echo "Download the recommended speedrunning mods (modpack) file to the ~/Downloads folder"
librewolf --new-window https://mods.tildejustin.dev/
read -p "Press any key to continue..."
/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -I ~/Downloads/1.16.1-random_seed.mrpack
read -p "Once mods fully imported, press any key to continue..."
rm ~/Downloads/1.16.1-random_seed.mrpack

/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -l MCSRRanked-Linux-1.16.1-Pro
/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -l 1.16.1-random_seed
/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -l Fabulously.Optimized-12.0.2
read -p "Ensure all instances have run to menu at least once before continuing."

# Set up MCSR standard settings.
cp ../data/configs/minecraft/standardsettings.json ~/.local/share/PrismLauncher/instances/MCSRRanked-Linux-1.16.1-Pro/minecraft/config/mcsr/standardsettings.json
cp ../data/configs/minecraft/standardsettings.json ~/.local/share/PrismLauncher/instances/1.16.1-random_seed/minecraft/config/mcsr/standardsettings.json
# Set up default minecraft instance settings.
cp ../data/configs/minecraft/options.txt ~/.local/share/PrismLauncher/instances/Fabulously.Optimized-12.0.2/minecraft/options.txt

# Download speedrunning practice maps - if i create folders it creates instances in different locations.
wget https://github.com/Dibedy/The-MCSR-Practice-Map/releases/download/latest/MCSR.Practice.v2.0.0.zip
unzip MCSR.Practice.v2.0.0.zip -d mcsrpractice
cp -r mcsrpractice ~/.local/share/PrismLauncher/instances/MCSRRanked-Linux-1.16.1-Pro/minecraft/saves
cp -r mcsrpractice ~/.local/share/PrismLauncher/instances/1.16.1-random_seed/minecraft/saves
cp -r mcsrpractice ~/.local/share/PrismLauncher/instances/Fabulously.Optimized-12.0.2/minecraft/saves
rm -rf mcsrpractice
rm MCSR.Practice.v2.0.0.zip

rm nohup.out
