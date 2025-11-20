# Run the script using the bash shell. 
#!/bin/bash 
set -e # Stop script execution if an error occurs. 

sudo apt update && sudo apt upgrade -y # If updating the package database succeeds, update packages to their latest version.
echo "[PROGRESS] Package database updated and all packages upgraded."

cp ./configs/.xinputrc $HOME/.xinputrc # Copy my xinput config file to my home directoy.
echo "[PROGRESS] Set up .xinputrc file."

echo "[PROGRESS] Logging out now to apply relevant changes."
loginctl terminate-session "$XDG_SESSION_ID"
