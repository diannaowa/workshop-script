#!/bin/bash

# Copyright 2014 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


ETCD_SERVERS=${1:-"http://8.8.8.18:4001"}
FLANNEL_NET=${2:-"172.16.0.0/16"}


cat <<EOF >/opt/kubernetes/cfg/flannel
FLANNEL_ETCD="-etcd-endpoints=${ETCD_SERVERS}"
FLANNEL_ETCD_KEY="-etcd-prefix=/coreos.com/network"
EOF

cat <<EOF >/etc/systemd/system/flannel.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/flannel
ExecStart=/usr/bin/flanneld --ip-masq \${FLANNEL_ETCD} \${FLANNEL_ETCD_KEY}

Type=notify

[Install]
WantedBy=multi-user.target
EOF


systemctl enable flannel
systemctl daemon-reload
systemctl restart flannel
