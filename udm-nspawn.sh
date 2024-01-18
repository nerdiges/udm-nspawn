#!/bin/bash
##############################################################################################
#
# Description:
# ------------
#       During unifiOS updates some of the information necessary to run nspawn containers may
#       be deleted. This includes the installaed nspawn Debian packages as well as the links 
#       to the containers in /var/lib/machines necessary to use machinectl.
#       This script restores the necessary Debian packages as well as the /var/lib/machines 
#       links  once they are deleted during updates.
#       In addition, this script also creates the MAC VLAN bridges used to connect the 
#       containers to the VLANs configured in UDM-Pro.
#
#       Further Details about UDM-Pro and nspawn containers: 
#       - https://github.com/unifi-utilities/unifios-utilities/tree/main/nspawn-container
#
##############################################################################################

##############################################################################################
#
# Configuration
#

# Directory used to buffer offline copies of *.deb files for offline restore
dpkg_dir="$(dirname $0)/dpkg"

# Directory with brmac setup scripts
brmac_dir="$(dirname $0)/brmac"

# Storage for nspawn containers
machine_dir="/data/custom/machines"

#
# No further changes should be necessary beyond this line.
#
######################################################################################

# set scriptname
me=$(basename $0)

# include local configuration if available
[ -e "$(dirname $0)/${me%.*}.conf" ] && source "$(dirname $0)/${me%.*}.conf"

# install systemd-container if it's not installed. 
if ! dpkg -l systemd-container | grep ii >/dev/null; then
    if ! apt -y install systemd-container debootstrap; then
        yes | dpkg -i "${dpkg_dir}/*.deb"
    fi
fi

# setup all MAC VLAN Bridges for the containers
# MAC VLAN Bridges are created based on scripts br*mac.sh that must be
# located in same directory like this script
for i in "${brmac_dir}/br*mac.sh"; do 
    logger "$me: Setting up macvlan bridge $i."
    $i; 
done

# links any containers from $machine_dir to /var/lib/machines.
mkdir -p /var/lib/machines
for machine in $(basename $(find "${machine_dir}/" -mindepth 1 -maxdepth 1 -type d)); do
	if [ ! -e "/var/lib/machines/$machine" ]; then
		ln -s "${machine_dir}/$machine" "/var/lib/machines/"
		machinectl enable $machine
		machinectl start $machine
	fi
done
