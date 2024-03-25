#!/bin/bash

# is user root?
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ser ejecutado como root" 
    exit 1
fi

#Updating dnf.conf
# content to copy dnf.conf
DNF_CONF_CONTENT="[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
# Added for speed
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True"

# path dnf.conf
DNF_CONF_PATH="/etc/dnf/dnf.conf"

# saving content into dnf.conf
echo "$DNF_CONF_CONTENT" > "$DNF_CONF_PATH"

echo "dnf.conf has been updated."

# RPM fusion installation
rpmfusion_free_url="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
rpmfusion_nonfree_url="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

echo "Downloading and install RPM FUSION..."
dnf install -y "$rpmfusion_free_url" "$rpmfusion_nonfree_url"

echo "RPM Fusion has been installed."

# Installing aditionals

echo "Updating multimedia, sound and video groups..."
dnf -y groupupdate multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin && dnf -y groupupdate sound-and-video

echo "Installing Intel drivers..."
dnf -y install intel-media-driver

echo ""
dnf -y install rpmfusion-free-release-tainted && dnf -y install libdvdcss && dnf -y install rpmfusion-nonfree-release-tainted

dnf -y --repo=rpmfusion-nonfree-tainted install "*-firmware"

# Removing bloat
dnf -y remove $(grep "^[^#]" bloatware)

# install wanted apps
echo -e "Installing applications ..."

dnf -y update || true

dnf -y --setopt=install_weak_deps=False install \
    dconf \
    dnf-automatic \
    gnome-shell-extension-dash-to-dock \
    gnome-tweaks \
    vlc \
    keepassxc \
    kitty \
    qbittorrent \
    audacity \
    

dnf -y update
dnf -y autoremove

reboot
