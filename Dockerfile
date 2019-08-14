# vim:set ft=dockerfile:
# Debian Postfix
FROM debian:stable-slim

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

# explicitly set user/group IDs
#
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		net-tools \
		perl \
		perl-modules \
		debconf-utils \
		apt-utils \
		; \
	rm -rf /var/lib/apt/lists/*; \
#
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		glusterfs-client \
		glusterfs-common \
		glusterfs-server \
		libgfapi0 \
		libgfchangelog0 \
		libgfdb0 \
		libgfrpc0 \
		libgfxdr0 \
		libglusterfs0 \
		; \
	rm -rf /var/lib/apt/lists/*; \
	echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
# postfix
ENV POSTFIX_CHROOT "/var/spool/postfix"
RUN set -ex; \
	# Build chroot
	apt-get update; \
	apt-get install -y --no-install-recommends \
		binutils \
		debootstrap \
		; \
	rm -rf /var/lib/apt/lists/*; \
	mkdir $POSTFIX_CHROOT; \
	debootstrap --arch $(dpkg --print-architecture) stable $POSTFIX_CHROOT http://deb.debian.org/debian; \
	# Postfix configuration
	echo "postfix postfix/mailname string your.hostname.com" | debconf-set-selections; \
	echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections; \
	# echo "postfix postfix/main_mailer_type select smarthost" | chroot $POSTFIX_CHROOT debconf-set-selections; \
	# echo "postfix postfix/mailname string $hostname.localdomain" | chroot $POSTFIX_CHROOT debconf-set-selections; \ 
	# echo "postfix postfix/relayhost string smtp.localdomain" | chroot $POSTFIX_CHROOT debconf-set-selections; \
	apt-get update && apt-get install -y --no-install-recommends \
		postfix \
		postgrey \
		rrdtool \
		mailgraph \
		; \
	rm -rf /var/lib/apt/lists/*
RUN set -eux; \
	apt-get update; \
	apt-get install -y gosu; \
	rm -rf /var/lib/apt/lists/*; \
# verify that the binary works
	gosu nobody true
