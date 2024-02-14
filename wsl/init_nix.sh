#!/bin/bash

set -eu

HOMEMANAGER_BRANCH="release-23.11"

mkdir -p ${HOME}/.config/nix
echo "experimental-features = nix-command flakes" >> ${HOME}/.config/nix/nix.conf

sh <(curl -L https://nixos.org/nix/install) --no-daemon
echo 'if [ -e "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then . "${HOME}/.nix-profile/etc/profile.d/nix.sh"; fi' >> "${HOME}/.bashrc"
. ${HOME}/.nix-profile/etc/profile.d/nix.sh

nix run home-manager/$HOMEMANAGER_BRANCH -- init --switch