#!/bin/bash


MASTER_ADDRESS=${1:-"8.8.8.18"}

cat <<EOF >/opt/kubernetes/cfg/kube-scheduler
###
# kubernetes scheduler config

# --logtostderr=true: log to standard error instead of files
KUBE_LOGTOSTDERR="--logtostderr=true"

# --v=0: log level for V logs
KUBE_LOG_LEVEL="--v=4"

KUBE_MASTER="--master=${MASTER_ADDRESS}:8080"

# --leader-elect
KUBE_LEADER_ELECT="--leader-elect"

# Add your own!
KUBE_SCHEDULER_ARGS=""

EOF

KUBE_SCHEDULER_OPTS="   \${KUBE_LOGTOSTDERR}     \\
                        \${KUBE_LOG_LEVEL}       \\
                        \${KUBE_MASTER}          \\
                        \${KUBE_LEADER_ELECT}    \\
                        \$KUBE_SCHEDULER_ARGS"

cat <<EOF >/etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-scheduler
ExecStart=/usr/bin/kube-scheduler ${KUBE_SCHEDULER_OPTS}
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-scheduler
systemctl restart kube-scheduler
