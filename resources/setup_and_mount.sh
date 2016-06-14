#!/bin/sh

# We need either the token or the environment variables to access the user's drive.
# For details, see: http://acd-cli.readthedocs.io/en/latest/authorization.html
#
# You have to create an Amazon developer account to get these
if [ "$CLIENT_ID" != "" -a "$CLIENT_SECRET" != "" ] ; then
	mkdir -p /root/.cache/acd_cli
	rm -f /root/.cache/acd_cli/client_data
	echo "{"                                          >> /root/.cache/acd_cli/client_data
	echo "  \"CLIENT_ID\":     \"$CLIENT_ID\","       >> /root/.cache/acd_cli/client_data
	echo "  \"CLIENT_SECRET\": \"$CLIENT_SECRET\""    >> /root/.cache/acd_cli/client_data
	echo "}"                                          >> /root/.cache/acd_cli/client_data
	echo 'Created "client_data" file containing your ID and SECRET'
# This will expire in 1 hour, so it's mainly useful for testing purposes
elif [ -f /resources/oauth_data ] ; then
	mkdir -p /root/.cache/acd_cli
	cp /resources/oauth_data /root/.cache/acd_cli/
	echo 'Copied "oauth_data" into place'
else
	echo '"resources/oauth_data", "CLIENT_ID", and "CLIENT_SECRET" are missing.'
	echo "Supply either an oauth_data file, or configure the environment variables."
	exit 1
fi

# Attempt to initialize
acd_cli sync && acd_cli -v init

if [ "$?" = "0" ] ; then
	echo 'Initialized acd_cli'
else
	echo 'Failed to initialize acd_cli'
	exit 1
fi

# Attempt to mount with FUSE
export LIBFUSE_PATH="/usr/lib/libfuse.so.2"
acd_cli mount /mnt/amazon

if [ "$?" = "0" ] ; then
	echo 'Mounted your Amazon Cloud Drive at "/mnt/amazon"'
else
	echo 'Failed to mount Amazon Cloud Drive'
	exit 1
fi
