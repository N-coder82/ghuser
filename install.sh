#!/bin/bash

# ====== Script Info ======
#title          :install.sh
#description    :Installs ghuser.
#author         :N-coder82
#date           :5/18/24
#version        :1.0
#usage          :bash install.sh
#notes          :Install Curl to use this script.
#bash_version   :3.2.57(1)-release
# =========================
error_exit() {
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    echo -e "${RED}An error occured:${NC} Please try again."
    rm -rf "$TMPDIR/ghuser"
}
echo "Installing ghuser..."
mkdir "$TMPDIR/ghuser"
cd "$TMPDIR/ghuser" || error_exit
curl -O https://raw.githubusercontent.com/N-coder82/ghuser/main/ghuser.sh
mv ghuser.sh /usr/local/bin/ghuser
cd ..
rm -rf "$TMPDIR/ghuser"
echo Done!