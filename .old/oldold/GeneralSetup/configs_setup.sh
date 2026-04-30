#!/bin/bash

# Polybar
if [ ! -d ~/.config/polybar ]; then
  mkdir ~/.config/polybar
fi
cp -f ./configs/polybar ~/.config/polybar/config.ini
echo "[PROGRESS] Set up polybar config."

# i3 
cp -f ./configs/i3 ~/.config/i3/config
echo "[PROGESS] Set up i3 config."

# xinput
cp -f ./configs/.xinputrc ~/.xinputrc 
echo "[PROGRESS] Set up .xinputrc file."

# bashrc & bash_aliases
cp -f ./configs/.bashrc ~/.bashrc
cp -f ./configs/.bash_aliases ~/.bash_aliases
source ~/.bashrc ~/.bash_aliases
echo "[PROGRESS] Set up .bashrc and .bash_aliases - aliases set up."
