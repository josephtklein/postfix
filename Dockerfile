# vim:set ft=dockerfile:
FROM debian:stable-slim

RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
			postfix \
			net-tools \
			#perl \
			postgrey \
			pflogsumm \
			amavisd-new \
			rrdtool \
			mailgraph \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

# explicitly set user/group IDs
