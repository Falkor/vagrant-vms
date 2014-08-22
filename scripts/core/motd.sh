#! /bin/bash
################################################################################
# motd.sh - Create the proper MOTD with style.  
# Creation : 21 Aug 2014
# Time-stamp: <Ven 2014-08-22 17:02 svarrette>
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
# $Id$ 
#
# Description : see the print_help function or launch 'motd.sh --help'
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 
################################################################################


# Assumes figlet and facter are installed 

MOTD="/etc/motd"

#==========  Default Config =============
NAME="${MOTD_NAME}"
TITLE="${MOTD_TITLE}"
SUBTITLE="${MOTD_SUBTITLE}"
DESC="${MOTD_DESC}"
HOSTNAME=`hostname -f`
SUPPORT_MAIL="${MOTD_SUPPORT}"
#========================================

print_usage() {
    cat <<EOF
    $0 [--name "vagrant box name"] \
       [--title "Title"] \
       [--subtitle "Subtitle"] \
       [--desc "description"] \
       [--suppoort "support@mail.com"] 

This will generate the appropriate ${MOTD} file
EOF
}

# Parse the command-line options
while [ $# -ge 1 ]; do
    case $1 in
        -h | --help)    print_usage;       exit 0;;
        -V | --version) print_version;     exit 0;;
        -n | --name)      shift; NAME=$1;;
        -t | --title)     shift; TITLE=$1;;
        -m2| --msg2)      shift; MSG2=$1;;
        -d | --desc)      shift; DESC=$1;;
        -s | --support)   shift; SUPPORT_MAIL=$1;;
    esac
    shift
done

cat <<MOTD_EOF > ${MOTD}
---
`env`
$#
$*
================================================================================
 Welcome to the Vagrant box ${NAME}
================================================================================
MOTD_EOF
if [ -n "$TITLE" ]; then
    figlet -w 80 -c "${TITLE}" >>  ${MOTD}
fi
if [ -n "$MSG2" ]; then
    figlet -w 80 -c "${MSG2}" >>  ${MOTD}
fi
cat <<MOTD_EOF >> ${MOTD}
================================================================================
    Hostname.... `hostname -f`
    OS.......... `facter --yaml | grep lsbdistdescription | cut -d ':' -f 2`
    Support..... ${SUPPORT_MAIL}
    Docs........ Vagrant: http://docs.vagrantup.com/v2/

    ${DESC}         
================================================================================
MOTD_EOF
