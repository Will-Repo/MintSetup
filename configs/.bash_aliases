# Run by .bashrc`:wa

alias mc='flatpak run org.prismlauncher.PrismLauncher'
alias prismmc='flatpak run org.prismlauncher.PrismLauncher'
alias discord='flatpak run com.discordapp.Discord'
alias signout='i3-msg exit'
alias browser='librewolf' 
alias github='browser https://github.com/'
alias myuob='browser https://myuob.bham.ac.uk/dashboard/student-home'
alias msteams='browser https://teams.microsoft.com/v2/'
alias closeall='i3-msg "[class=\".*\"] kill"'
alias add='git add .'
alias commit='git commit -m'
alias ac='git add . && git commit -m'
alias push='git push origin main'
alias gdrive='rclone mount gdrive: ~/Remote/gdrive --vfs-cache-mode full & > /dev/null && cd ~/Remote/gdrive'
alias stopgdrive='fusermount -u ~/Remote/gdrive'
#alias gphotos='rclone mount gphotos: ~/Remote/gphotos --vfs-cache-mode full & > /dev/null && cd ~/Remote/gphotos'
#alias stopgphotos='fusermount -u ~/Remote/gphotos'
#alias oduni='rclone mount oduni: ~/Remote/oduni --vfs-cache-mode full & > /dev/null && cd ~/Remote/oduni' # One drive uni - uni doesnt allow rclone :(
#alias stopoduni='fusermount -u ~/Remote/oduni'
alias odgoogle='rclone mount odgoogle: ~/Remote/odgoogle --vfs-cache-mode full & > /dev/null && cd ~/Remote/odgoogle' # One drive google account
alias stopodgoogle='fusermount -u ~/Remote/odgoogle'
alias n='nvim'
alias ytmusic='browser https://music.youtube.com/playlist?list=PLmiqf5NkGrMQVAk0eCf9PqR7Lj70j3IkB'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

canvas() {
    if [ -z "$1" ]; then
	    browser https://birmingham.instructure.com/
	    return
    fi
    case "$1" in
	    ra)
		browser https://birmingham.instructure.com/courses/83568 
		;;
	    oop) 
		browser https://birmingham.instructure.com/courses/83754
		;;
	    cspp)
		browser https://birmingham.instructure.com/courses/83083
		;;
	    vgla) 
		browser https://birmingham.instructure.com/courses/83562
		;;
	    *)
		echo "Invalid parameter."
		;;
    esac
}

panopto() {
    if [ -z "$1" ]; then
	    browser https://bham.cloud.panopto.eu/Panopto/Pages/Home.aspx
	    return
    fi
    case "$1" in
	    ra)
		browser https://bham.cloud.panopto.eu/Panopto/Pages/Sessions/List.aspx#folderQuery=%22real%20ana%22&folderID=%22924f2eaa-1262-4bff-a6bc-b35a014e9bb7%22
		;;
	    oop) 
		browser https://bham.cloud.panopto.eu/Panopto/Pages/Sessions/List.aspx#folderQuery=%22object%22&folderID=%22ecb1acb1-c45c-4e86-9790-b36f007c2c0d%22
		;;
	    cspp)
		browser https://bham.cloud.panopto.eu/Panopto/Pages/Sessions/List.aspx#folderQuery=%22computer%20sy%22&folderID=%2216d447d3-5de9-4a88-afb5-b35a014d5bf3%22
		;;
	    vgla) 
		browser https://bham.cloud.panopto.eu/Panopto/Pages/Sessions/List.aspx#folderQuery=%22vgla%22&folderID=%220a13a288-ae0a-4e59-b153-b35a014e9a66%22
		;;
	    *)
		echo "Invalid parameter."
		;;
    esac
}

# Allow volume to be changed by either volume or vol.
volume() {
    pactl set-sink-volume @DEFAULT_SINK@ $1%
}
alias vol='volume'
alias v='volume'

#AFNOM
alias zap='flatpak run org.zaproxy.ZAP'
alias osintframework='browser https://osintframework.com/'
alias googlesearch='browser https://www.google.co.uk/advanced_search'
alias tineye='browser https://tineye.com/'
alias stegsolve='java -jar /usr/local/bin/stegsolve.jar "$@"' #preserve arguments passed to the alias.
alias ghidra='/opt/ghidra/ghidraRun'
