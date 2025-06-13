for daemon in $(ls /Library/LaunchDaemons/ | grep -e websense -e forcepoint); do sudo launchctl unload -w "/Library/LaunchDaemons/"$daemon ; done
