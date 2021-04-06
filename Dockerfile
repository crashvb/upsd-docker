FROM crashvb/supervisord:202103212252
LABEL maintainer "Richard Davis <crashvb@gmail.com>"

# Install packages, download files ...
RUN docker-apt libnss3-tools nut-server ssl-cert

# Configure: upsd
ENV NUT_CONFPATH=/etc/nut
ADD nut-* /usr/local/bin/
RUN usermod --append --groups ssl-cert nut && \
	install --directory --group=root --mode=0775 --owner=root ${NUT_CONFPATH}/conf.d/ ${NUT_CONFPATH}/users.d/ /usr/local/share/nut && \
	sed --expression="/^MODE=/s/none/netserver/" \
		--in-place=.dist ${NUT_CONFPATH}/nut.conf && \
	sed --expression="/^# you'll need to restart upsd/a LISTEN 0.0.0.0 3493" \
		--expression="/^# CERTPATH \/usr/cCERTPATH /etc/nut/nss" \
		--in-place=.dist ${NUT_CONFPATH}/upsd.conf && \
	mv ${NUT_CONFPATH}/upsmon.conf ${NUT_CONFPATH}/upsmon.conf.dist && \
	mv ${NUT_CONFPATH} /usr/local/share/nut/config

# Configure: supervisor
ADD supervisord.upsd.conf /etc/supervisor/conf.d/upsd.conf

# Configure: entrypoint
ADD entrypoint.upsd /etc/entrypoint.d/upsd

EXPOSE 3493/tcp

VOLUME ${NUT_CONFPATH}
