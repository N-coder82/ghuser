#!/bin/bash

# ====== Script Info ======
#title          :install.sh
#description    :Installs $progname.
#author         :N-coder82
#date           :5/18/24
#version        :1.0
#usage          :bash install.sh
#notes          :Install Curl to use this script.
#bash_version   :3.2.57(1)-release
# =========================
#!/bin/bash
progname="ghuser"
error_exit() {
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    echo -e "${RED}An error occured:${NC} Please try again."
    rm -rf "$TMPDIR/$progname"
    exit 1
}
cd "$TMPDIR" || error_exit
echo "Downloading $progname..."
git clone https://github.com/N-coder82/$progname.git $progname
cd "$TMPDIR/$progname" || error_exit
curl -O https://raw.githubusercontent.com/N-coder82/$progname/main/$progname.sh || error_exit
chmod +x $progname.sh
sudo mv $progname.sh /usr/local/bin/$progname || error_exit
cd ..
rm -rf "$TMPDIR/$progname" || error_exit
echo Done!