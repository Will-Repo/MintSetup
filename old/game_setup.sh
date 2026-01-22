#!/bin/bash

echo "[PROGRESS] Do you wish to install Prism Launcher (for minecraft)? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	flatpak install -y --user flathub org.prismlauncher.PrismLauncher
fi

echo "[PROGRESS] Do you wish to install Steam? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
    sudo apt install steam -y
fi


echo "[PROGRESS] Do you wish to install Heroic Launcher? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
    flatpak install -y flathub com.heroicgameslauncher.hgl
fi

echo "[PROGRESS] Do you wish to install Lutris? (Y/n)"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	flatpak install -y --user flathub net.lutris.Lutris
fi

echo "[PROGRESS] Do you wish to install StepMania? (Y/n)"
read input 
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
    wget https://github.com/stepmania/stepmania/releases/download/v5.1.0a3/StepMania-5.1.0-Linux.tar.gz
    tar -xzvf StepMania-5.1.0-Linux.tar.gz
    rm -rf StepMania-5.1.0-Linux.tar.gz 
    sudo apt-get install -y libjpeg62-dev libpcre3 libpcre3-dev
    sudo ln -s /usr/lib/x86_64-linux-gnu/libva.so.2 /usr/lib/x86_64-linux-gnu/libva.so.1
    mv StepMania-5.1.0-Linux/ Games
    mkdir ~/Games/StepMania-5.1.0-Linux/stepmania-5.1/Songs/2013
    sudo ln -s ~/usb/stepmania/2013 ~/Games/StepMania-5.1.0-Linux/stepmania-5.1/Songs/
    mkdir ~/Games/StepMania-5.1.0-Linux/stepmania-5.1/Songs/2014
    sudo ln -s ~/usb/stepmania/2014 ~/Games/StepMania-5.1.0-Linux/stepmania-5.1/Songs/
fi

echo "[PROGRESS] Do you wish to install Osu? (Y/n)"
read input 
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
    wget https://github.com/ppy/osu/releases/latest/download/osu.AppImage
    chmod +x osu.AppImage
    mv /osu.AppImage ~/Games/
fi


