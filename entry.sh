#!/bin/sh
FIRSTLETTER=$(echo $AFS_USER | cut -c 1)
if [ ! -z ${AFS_USER} ]; then
	/usr/bin/aklog
	cd /afs/cern.ch/user/$FIRSTLETTER/$AFS_USER
fi
/bin/bash
