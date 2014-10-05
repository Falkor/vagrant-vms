#!/bin/sh
# Bootstrapping the VM with librarian-puppet.
#
# Credits: [purple52](https://github.com/purple52/librarian-puppet-vagrant/)
#
COLOR_RED="\033[0;31m"
COLOR_BACK="\033[0m"

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/etc/puppet/
PUPPETFILE_SRC=/tmp/Puppetfile

if [ -d '/vagrant' ]; then 
    [ -f '/vagrant/puppet/Puppetfile' ] && PUPPETFILE_SRC=/vagrant/puppet/Puppetfile
fi 

info() { 
    echo "==> $*" 
}
print_error_and_exit() {
    echo -e "${COLOR_RED}*** ERROR *** $*${COLOR_BACK}"
    exit 1
}

[ $UID -gt 0 ] && print_error_and_exit "You must be root to execute this script (current uid: $UID)"

# NB: librarian-puppet might need git installed. If it is not already installed
# in your basebox, this will manually install it at this point using apt or yum

$(which git > /dev/null 2>&1)
FOUND_GIT=$?
if [ "$FOUND_GIT" -ne '0' ]; then
    echo 'Attempting to install git.'
    $(which apt-get > /dev/null 2>&1)
    FOUND_APT=$?
    $(which yum > /dev/null 2>&1)
    FOUND_YUM=$?

    if [ "${FOUND_YUM}" -eq '0' ]; then
        yum -q -y makecache
        yum -q -y install git
        echo 'git installed.'
    elif [ "${FOUND_APT}" -eq '0' ]; then
        apt-get -q -y update
        apt-get -q -y install git
        echo 'git installed.'
    else
        echo 'No package installer available. You may need to install git manually.'
    fi
else
    info 'git found.'
fi

if [ ! -d "$PUPPET_DIR" ]; then
    info "creating ${PUPPET_DIR}"
    mkdir -p ${PUPPET_DIR}
fi

[ ! -f ${PUPPETFILE_SRC} ] && print_error_and_exit "unable to find the puppetfile  ${PUPPETFILE_SRC}"

info "copying ${PUPPETFILE_SRC} in ${PUPPET_DIR}"
cp ${PUPPETFILE_SRC} ${PUPPET_DIR}/

if [ "$(gem list -i '^librarian-puppet$')" == "false" ]; then 
    info "installing the 'librarian-puppet' gem"
    gem install librarian-puppet
    info "(clean) install librarian puppet configuration"
    cd ${PUPPET_DIR} && librarian-puppet install --clean --verbose
else
    info "updating librarian puppet configuration"
    cd ${PUPPET_DIR} && librarian-puppet update --verbose
fi
