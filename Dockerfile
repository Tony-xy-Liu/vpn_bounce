FROM alpine:edge

RUN apk add --update --no-cache \
        curl \
        openconnect \
        supervisor \
        openssh

ADD ./load/sshd_config      /etc/ssh/sshd_config
ADD ./load/supervisord.conf /etc/supervisord.conf
ADD ./load/openssl.conf     /etc/openssl.conf
ADD ./load/bin/*            /usr/local/bin/

ENV OPENSSL_CONF=/etc/openssl.conf
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir -p /ws
RUN ln -s /proc/sys/net/ipv4/route/flush /ws/flush

EXPOSE 22
ENTRYPOINT [ "entry" ]
