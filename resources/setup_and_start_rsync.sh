#!/bin/sh

# The rsyncclient's password must be specified as an environment variable
if [ "$RSYNC_PASSWORD" = "" ] ; then
	echo '"RSYNC_PASSWORD" environment variable was undefined'
	exit 1
else
	# Create the secrets file, based on the environment variable
	touch /etc/rsyncd.secrets
	chmod 600 /etc/rsyncd.secrets
	echo "rsyncclient:$RSYNC_PASSWORD" >> /etc/rsyncd.secrets

	# The path which rsync will serve
	printf "\tpath = /mnt/amazon/$AMAZON_DRIVE_SUBDIRECTORY\n" >> /etc/rsyncd.conf

	# If RSYNC_HOSTS_ALLOW is defined, add it to the config
	if [ "$RSYNC_HOSTS_ALLOW" != "" ] ; then
		printf "\thosts allow = $RSYNC_HOSTS_ALLOW\n" >> /etc/rsyncd.conf
	fi

	# Start rsync
	rsync --daemon
	echo 'The rsync daemon is accessible to the "rsyncclient" user with your "RSYNC_PASSWORD"'
fi
