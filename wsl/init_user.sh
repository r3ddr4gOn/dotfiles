#!/bin/bash

useradd -m -G adm,dialout,cdrom,floppy,sudo,audio,dip,video,plugdev,netdev -s /bin/bash $1

echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo_nopasswd

cat <<- EOF > /etc/wsl.conf
	[user]
	default=$1
EOF