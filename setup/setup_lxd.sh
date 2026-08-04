#!/usr/bin/env bash
set -euo pipefail

LXD_BRIDGE="labbr0"
LXD_BRIDGE_ADDR="10.200.10.1/24"
LXD_STORAGE_POOL="default"
LXD_STORAGE_DRIVER="dir"

install_snapd() {
  if command -v snap >/dev/null 2>&1; then
    echo "snap is already installed."
    return
  fi

  echo "Installing snapd..."
  sudo apt-get update
  sudo apt-get install -y snapd
  sudo systemctl enable --now snapd.socket

  if [ ! -e /snap ]; then
    sudo ln -s /var/lib/snapd/snap /snap
  fi
}

install_lxd() {
  if snap list lxd >/dev/null 2>&1; then
    echo "lxd is already installed."
    return
  fi

  echo "Installing lxd..."
  sudo snap install lxd
}

init_lxd() {
  sudo lxd waitready

  if sudo lxc network show "${LXD_BRIDGE}" >/dev/null 2>&1; then
    echo "LXD network ${LXD_BRIDGE} already exists. Skip lxd init."
    return
  fi

  cat > /tmp/lxd-preseed.yaml <<EOF
config: {}

networks:
- name: ${LXD_BRIDGE}
  description: "LXD bridge for bootcamp-ansible containers"
  type: bridge
  project: default
  config:
    ipv4.address: ${LXD_BRIDGE_ADDR}
    ipv4.nat: "true"
    ipv6.address: none

storage_pools:
- name: ${LXD_STORAGE_POOL}
  driver: ${LXD_STORAGE_DRIVER}
  config: {}

storage_volumes: []

profiles:
- name: default
  description: "Default LXD profile"
  config: {}
  devices:
    root:
      path: /
      pool: ${LXD_STORAGE_POOL}
      type: disk
    eth0:
      name: eth0
      network: ${LXD_BRIDGE}
      type: nic

projects: []
cluster: null
EOF

  sudo lxd init --preseed < /tmp/lxd-preseed.yaml
}

install_snapd
install_lxd
init_lxd

sudo lxc network show "${LXD_BRIDGE}"
sudo lxc profile show default

echo "LXD setup completed."
