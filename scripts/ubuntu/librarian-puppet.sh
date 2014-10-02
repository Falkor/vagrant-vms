#!/bin/sh
# Bootstrapping the VM with librarian-puppet.
#
# Credits: [purple52](https://github.com/purple52/librarian-puppet-vagrant/)
#

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/etc/puppet/
PUPPETFILE_SRC=/tmp/Puppetfile

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
    echo 'git found.'
fi

if [ ! -d "$PUPPET_DIR" ]; then
    mkdir -p ${PUPPET_DIR}
fi
cp ${PUPPETFILE_SRC} ${PUPPET_DIR}/

if [ "$(gem list -i '^librarian-puppet$')" = "false" ]; then
    gem install librarian-puppet --no-rdoc --no-ri
    # Changing metadata to #metadata in the Puppetfile file in the puppet directory
    # in order to make the "librarian-puppet install --clean" command to work properly.
    sed -i 's/metadata/#metadata/g' ${PUPPET_DIR}/Puppetfile
 
   cd ${PUPPET_DIR} && librarian-puppet install --clean
else
    cd ${PUPPET_DIR} && librarian-puppet update
fi
