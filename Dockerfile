# vim:set ft=dockerfile:
FROM debian:stable-slim

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
			net-tools \
			perl \
			perl-modules \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

# explicitly set user/group IDs
#
# postfix
RUN set -ex; \
	echo "postfix postfix/main_mailer_type select smarthost" | chroot $rootfs debconf-set-selections; \
	echo "postfix postfix/mailname string $hostname.localdomain" | chroot $rootfs debconf-set-selections; \ 
	echo "postfix postfix/relayhost string smtp.localdomain" | chroot $rootfs debconf-set-selections; \
	apt-get update && apt-get install -y --no-install-recommends postfix postgrey rrdtool mailgraph;
