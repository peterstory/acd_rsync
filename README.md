# acd_rsync README

Create a Docker container which will mount your Amazon Cloud Drive with FUSE, and allow remote access to its contents via the rsync daemon.

## Getting Started

Most of the setup is automated in the Dockerfile and in two helper scripts. But until the oauth authentication is automated, you need to run the helper scripts yourself, because they are interactive: you will be prompted to open a web browser and authenticate with your Amazon credentials. 

### .env File

The first thing you need to do is setup the ``.env`` file, which provides configuration for the scripts which run in your Docker container. 

Follow these steps to set up a "Security Profile," with will give you a CLIENT_ID and CLIENT_SECRET.
<https://acd-cli.readthedocs.io/en/latest/authorization.html>

Alternatively, you can follow the "Appspot" directions, and copy your ``oauth_data`` file into the ``resources`` folder.

Create a file name ``.env`` containing:

	# These are from your Amazon "Security Profile"
	CLIENT_ID=amzn1.application-oa2-client._UNIQUE_CODE_
	CLIENT_SECRET=_ANOTHER_UNIQUE_CODE_
	# Rsync will request this password for authentication
	RSYNC_PASSWORD=_A_PASSWORD_OF_YOUR_CHOICE_
	# Optional: restrict access by IP and/or hostname. For details, see the
	# "hosts allow" section of the "rsyncd.conf" man page.
	RSYNC_HOSTS_ALLOW=_IPS_AND_OR_HOSTNAMES_
	# Optional, but recommended: serve just a subdirectory from Amazon Drive.
	# This has the added benefit of preventing rsync from starting when your
	# Amazon Drive isn't mounted.
	AMAZON_DRIVE_SUBDIRECTORY=_SUBDIRECTORY_PATH_

### Start the Container

Start the container in the background.

	docker-compose up -d

### Mount Amazon Cloud Drive and Start Rsync

Enter the container:

	docker exec -it acdrsync_acd_rsync_1 /bin/sh

Within the container, run these scripts:

	/resources/setup_and_mount.sh && resources/setup_and_start_rsync.sh

Follow the instructions, and your cloud drive should be mounted, and rsync should provide access to its contents! 

## Using rsync

After your container is running and configured, you can send files to Amazon Cloud Drive via rsync. Note that the rsync protocol isn't encrypted, so if you need better security, you should wrap rsync in an SSH tunnel. 

Note that rsync typically depends on the last modified time of files to determine whether a file has been changed. Unfortunately, Amazon Cloud Drive doesn't store last modified times. As a workaround, you can tell rsync to only compare file sizes. Unfortunately, this means that if a file is modified but its file size doesn't change, it won't be re-copied by rsync.

	rsync --recursive --size-only -P SOURCE rsyncclient@HOSTNAME::amazon

When you're prompted for a password, supply the RSYNC_PASSWORD you choose above. 

## Known Problems

It's inconvenient to have to open a web browser to authenticate with Amazon. I plan to automate this step ASAP! 

After about a day, files stop copying. I'm investigating why this is the case. 
