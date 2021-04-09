#
#  Author: Kaumil Trivedi
#  Date: 2016-04-24 21:18:57 +0100 (Sun, 24 Apr 2016)
#
FROM harisekhon/hadoop:latest

RUN yum -y update; yum clean all
RUN yum -y install initscripts && yum clean all;
RUN yum -y install systemd; yum clean all; \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

COPY entrypoint.sh /entrypoint2.sh
COPY elastic.repo /etc/yum.repos.d/elastic.repo
COPY filebeat.yml /etc/filebeat/filebeat.yml
USER root
RUN chown root /etc/filebeat/filebeat.yml
RUN chmod go-w /etc/filebeat/filebeat.yml

ENV HDFS_NAMENODE_USER=hdfs
ENV HDFS_SECONDARYNAMENODE_USER=hdfs
ENV HDFS_DATANODE_USER=hdfs
ENV YARN_RESOURCEMANAGER_USER=yarn
ENV YARN_NODEMANAGER_USER=yarn

# CMD [ "/usr/sbin/init" ]
CMD ["/entrypoint2.sh"]

