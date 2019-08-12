# vim:set ft=dockerfile:
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
		glusterfs-server \
		; \
	rm -rf /var/lib/apt/lists/*; \
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
	# echo "postfix postfix/main_mailer_type select smarthost" | chroot $POSTFIX_CHROOT debconf-set-selections; \
	# echo "postfix postfix/mailname string $hostname.localdomain" | chroot $POSTFIX_CHROOT debconf-set-selections; \ 
	# echo "postfix postfix/relayhost string smtp.localdomain" | chroot $POSTFIX_CHROOT debconf-set-selections; \
	apt-get update && apt-get install -y --no-install-recommends \
		# postfix \
		# postgrey \
		rrdtool \
		mailgraph \
		; \
	rm -rf /var/lib/apt/lists/*; \
ENV GOSU_VERSION 1.11
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
		; \
	rm -rf /var/lib/apt/lists/*; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	{ command -v gpgconf > /dev/null && gpgconf --kill all || :; }; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true; \
	apt-get purge -y --auto-remove \
		ca-certificates \
		wget \
		; \
