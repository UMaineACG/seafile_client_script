#!/bin/bash

DATADIR="seafile-client"
DOWNLOAD="https://bintray.com/artifact/download/seafile-org/seafile/seafile-cli_4.3.2_x86-64.tar.gz"
FILENAME="seafile-cli_4.3.2_x86-64.tar.gz"
INSTALLPATH="./seafile-cli-4.3.2"
SEAFILE_SERVER="https://seafile.acg.maine.edu:443"

function check_distro () {
    # ----------------------------------------------------
    # If Debian/Ubuntu, adjust certs for Seafile-CLI https
    # --------------------------------------------------
        echo
        echo "You are running a version of Debian/Ubuntu. The Seafile-CLI checks for"
        echo -e "system CA certificates in locations used by CentOS. This script will"
        echo -e "now create symbolic links to your system certificates."
        echo
    if [ -f /etc/debian_version ]; then
        sudo mkdir -p /etc/pki/tls/certs
        sudo cp /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt
        sudo ln -s /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/cert.pem
    fi
}

function check_root () {
    # -------------------------------------------
    # If running as root, ask the user to ensure it.
    # -------------------------------------------
    username="$(whoami)"
    if [[ "${username}" == "root" ]]; then 
        echo
        echo "You are running this script as ROOT. This is not recommended."
        echo "Please re-run this script as non-root user."
        echo
        exit 1;
    fi
}

function welcome() {
    echo
    echo "--------------------------------------------------------------------------------"
    echo
    echo " This script will download and install the Seafile command-line client."
    echo " Please note, this script will create the necessary directories pertaining"
    echo -e " to the client's operation. Make sure you have sufficient permissions"
    echo -e " before executing this script. Press [ENTER] to continue"
    echo
    echo "--------------------------------------------------------------------------------"
    read dummy
    echo
}

function goodbye() {
    echo
    echo "********************************************************************************"
    echo
    echo " The setup is complete."
    echo -e " Your synced library can be found in the seafile-client directory."
    echo -e " To stop the seafile client, navigate to seafile-cli-4.3.2 and execute"
    echo " the following command: ./seaf-cli stop."
    echo " To restart the client, execute ./seaf-cli start."
    echo
    echo "********************************************************************************"
}

function get_seafile_client() {
    echo "Downloading Seafile client."
    wget ${DOWNLOAD}
    tar -xzvf ${FILENAME}
}

function initialize() {
    echo "Creating seafile client directory."
    echo
    mkdir "${DATADIR}"
    cd ${INSTALLPATH}
    echo "Initializing Seafile data directory."
    ./seaf-cli init -d "../${DATADIR}"
    echo
    echo "Starting Seafile client."
    ./seaf-cli start
    cd ../
}

function download_library() {
    echo
    echo "Please enter the id of the Seafile library you want to sync."
    echo "You can retrive the id by viewing the library through the Seafile web console."
    echo "The id is the portion of the url following /repo/."
    echo
    printf "Library ID: "
    read libid
    echo
    echo "Downloading Seafile library. You must provide your ACG Seafile credentials."
    cd ${INSTALLPATH}
    ./seaf-cli download -l ${libid} -s ${SEAFILE_SERVER} -d "../${DATADIR}"
}
function modify_bashrc() {
    echo
    echo 'if pgrep "ccnet" > /dev/null' >> ~/.bashrc
    echo 'then echo "Seafile VM client sync is running"' >> ~/.bashrc
    echo 'else cd /seafile-cli-4.3.2/' >> ~/.bashrc
    echo '"Starting Seafile VM client sync."' >> ~/.bashrc
    echo './seaf-cli start' >> ~/.bashrc
    echo 'fi' >> ~/.bashrc
    echo
}

# -------------------------------------------
# Main workflow of this script 
# -------------------------------------------

check_distro;
sleep .5
check_root;
sleep .5
welcome;
sleep .5
get_seafile_client;
sleep .5
initialize;
sleep .5;
download_library; 
sleep .5;
modify_bashrc;
goodbye;
