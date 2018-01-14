#!/bin/bash



ETCD_SERVERS=${1:-"http://8.8.8.18:4001"}
FLANNEL_NET=${2:-"172.16.0.0/16"}

# Store FLANNEL_NET to etcd.
attempt=0
while true; do
  ETCDCTL_API=3 && /usr/bin/etcdctl \
    --no-sync -C ${ETCD_SERVERS} \
    get /coreos.com/network/config >/dev/null 2>&1
  if [[ "$?" == 0 ]]; then
    break
  else
    if (( attempt > 600 )); then
      echo "timeout for waiting network config" > ~/kube/err.log
      exit 2
    fi

    ETCDCTL_API=3 && /usr/bin/etcdctl \
      --no-sync -C ${ETCD_SERVERS} \
      mk /coreos.com/network/config "{\"Network\":\"${FLANNEL_NET}\"}" >/dev/null 2>&1
    attempt=$((attempt+1))
    sleep 3
  fi
done
wait

