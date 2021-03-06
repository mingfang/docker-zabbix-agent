FROM ubuntu:14.04
  
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

#Your Instructions Here
RUN apt-get install -y build-essential

#Sensors
RUN apt-get install -y lm-sensors

#Zabbix
RUN wget -O - http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.2/zabbix-3.0.2.tar.gz | tar zx
RUN mv /zabbix* /zabbix

RUN cd /zabbix && \
    ./configure --enable-agent && \
    make -j8 && \
    make install

RUN groupadd zabbix && \
    useradd -g zabbix zabbix

COPY zabbix_agentd.conf /usr/local/etc/

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
