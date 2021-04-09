#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Kaumil Trivedi


set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export JAVA_HOME="${JAVA_HOME:-/usr}"

export PATH="$PATH:/hadoop/sbin:/hadoop/bin"

rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

yum install filebeat -y
chkconfig --add filebeat
chkconfig filebeat on

# service filebeat -c /etc/filebeat/filebeat.yml run

# systemctl start filebeat
# systemctl enable filebeat

if [ $# -gt 0 ]; then
    exec $@
else
    if ! [ -f /root/.ssh/authorized_keys ]; then
        ssh-keygen -t rsa -b 1024 -f /root/.ssh/id_rsa -N ""
        cp -v /root/.ssh/{id_rsa.pub,authorized_keys}
        chmod -v 0400 /root/.ssh/authorized_keys
    fi

    if ! [ -f /etc/ssh/ssh_host_rsa_key ]; then
        /usr/sbin/sshd-keygen || :
    fi

    if ! pgrep -x sshd &>/dev/null; then
        /usr/sbin/sshd
    fi
    echo
    SECONDS=0
    while true; do
        if ssh-keyscan localhost 2>&1 | grep -q OpenSSH; then
            echo "SSH is ready to rock"
            break
        fi
        if [ "$SECONDS" -gt 20 ]; then
            echo "FAILED: SSH failed to come up after 20 secs"
            exit 1
        fi
        echo "waiting for SSH to come up"
        sleep 1
    done
    echo
    if ! [ -f /root/.ssh/known_hosts ]; then
        ssh-keyscan localhost || :
        ssh-keyscan 0.0.0.0   || :
    fi | tee -a /root/.ssh/known_hosts
    hostname=$(hostname -f)
    if ! grep -q "$hostname" /root/.ssh/known_hosts; then
        ssh-keyscan $hostname || :
    fi | tee -a /root/.ssh/known_hosts

    mkdir -pv /hadoop/logs

    sed -i "s/localhost/$hostname/" /hadoop/etc/hadoop/core-site.xml

    start-dfs.sh
    start-yarn.sh

    useradd nifi
    hdfs dfs -mkdir /dfs-data
    hdfs dfs -chown nifi: /dfs-data
    hdfs dfs -chmod -R 777 /dfs-data
    useradd jovyan
    hdfs dfs -mkdir /csv-data
    hdfs dfs -chown jovyan: /csv-data
    hdfs dfs -chmod -R 777 /csv-data

    filebeat -c /etc/filebeat/filebeat.yml run

    rm /usr/lib/tmpfiles.d/systemd-nologin.conf
    tail -f /dev/null /hadoop/logs/*
    exec /usr/sbin/init
    stop-yarn.sh
    stop-dfs.sh
fi