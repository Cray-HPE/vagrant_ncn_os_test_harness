#!/usr/bin/env bash

SCRIPT_DIR=/vagrant
source /etc/environment
source /etc/cray/vagrant_image.bom

function download_file() {
    PATH_LOCAL_FILE=$1
    DOWNLOAD_URL=$2
    echo "Downloading file from $DOWNLOAD_URL"
    curl -L -u $PATH_LOCAL_FILE $DOWNLOAD_URL
}

function fetch_zypper_repos() {
    mkdir -p $SCRIPT_DIR/repos
    REPO_MANIFESTS=(
        conntrack.spec
        cray.repos
        google.template.repos
        hpe.template.repos
        suse.template.repos
    )
    for REPO_MANIFEST in ${REPO_MANIFESTS[*]}; do
        download_file $SCRIPT_DIR/repos/$REPO_MANIFEST "https://raw.githubusercontent.com/Cray-HPE/csm-rpms/${RELEASE_BRANCH}/repos/${REPO_MANIFEST}"
    done
    # Also fetch the script used to populate them.
    download_file $SCRIPT_DIR/repos/rpm-functions.sh "https://raw.githubusercontent.com/Cray-HPE/csm-rpms/${RELEASE_BRANCH}/scripts/rpm-functions.sh"
    chmod +x $SCRIPT_DIR/repos/rpm-functions.sh
    # Silence the echo of credential.
    sed -i 's/echo "Adding repo ${alias} at ${url}"/# echo "Adding repo ${alias} at ${url}"/g' $SCRIPT_DIR/repos/rpm-functions.sh
}
fetch_zypper_repos

cd /vagrant/repos
source ./rpm-functions.sh
add-cray-repos
add-google-repos
add-hpe-repos
add-suse-repos
add-fake-conntrack
zypper lr -e /tmp/repos.repos
cat /tmp/repos.repos
cd $OLDPWD
