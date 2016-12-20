#!/bin/sh
if [ ! -z ${AFS_USER} ]; then
	/usr/bin/aklog
	cd /afs/cern.ch/user/r/$AFS_USER
fi
/bin/bash
