# Alpine is a tiny distro.
# If you want to build on a non-ARM platform, use the following line instead:
# FROM alpine:3.2
FROM container4armhf/armhf-alpine:3.2
MAINTAINER Peter Story <peter.garth.story@gmail.com>

# Install acd_cli
RUN echo "http://dl-4.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories
RUN apk add python3 git fuse
RUN pip3 install fusepy
RUN pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git

# Install rsync
RUN apk add rsync

# Copy resources into place
RUN mkdir /resources
ADD resources/setup_and_mount.sh       /resources
ADD resources/setup_and_start_rsync.sh /resources
ADD resources/rsyncd.conf              /etc/rsyncd.conf

# The mount
RUN mkdir -p /mnt/amazon

# Setup acd_cli and rsync, then start rsync
# /resources/setup_and_mount.sh && resources/setup_and_start_rsync.sh
CMD touch /tmp/test && tail -f /tmp/test
