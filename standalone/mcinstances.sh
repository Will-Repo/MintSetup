# Can't do this atomatically as it requires manual input in windows.
/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -I "https://github.com/Fabulously-Optimized/fabulously-optimized/releases/download/v12.0.2/Fabulously.Optimized-12.0.2.zip"
/opt/prismlauncher/PrismLauncher-Linux-x86_64.AppImage -I "https://redlime.github.io/MCSRMods/modpacks/v4/MCSRRanked-Linux-1.16.1-Pro.mrpack"
mkdir -p ~/.local/share/PrismLauncher/instances/MCSRRanked-Linux-1.16.1-Pro/minecraft/config/mcsr/
cp ../data/configs/standardsettings.json ~/.local/share/PrismLauncher/instances/MCSRRanked-Linux-1.16.1-Pro/minecraft/config/mcsr/standardsettings.json
