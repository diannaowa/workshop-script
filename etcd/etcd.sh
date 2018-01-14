#!/bin/bash

etcd_data_dir=/var/lib/etcd
mkdir -p ${etcd_data_dir}

ETCD_NAME=${1:-"default"}
ETCD_LISTEN_IP=${2:-"0.0.0.0"}
ETCD_INITIAL_CLUSTER=${1:-}

cat <<EOF >/opt/kubernetes/cfg/etcd.conf
# [member]
ETCD_NAME="${ETCD_NAME}"
ETCD_DATA_DIR="${etcd_data_dir}/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="https://${ETCD_LISTEN_IP}:2379"
EOF

cat <<EOF >/etc/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
WorkingDirectory=${etcd_data_dir}
EnvironmentFile=-/opt/kubernetes/cfg/etcd.conf
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=\$(nproc) /usr/bin/etcd"
Type=notify

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl restart etcd
