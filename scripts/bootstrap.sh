#!/bin/bash -x

########## Initial setup

# Disable swap
swapoff -a

# Set up hostnames
echo "
${control_plane_private_ip} ${control_plane_hostname}
${worker_1_private_ip} ${worker_1_hostname}
${worker_2_private_ip} ${worker_2_hostname}" >>/etc/hosts

# Override hostname
hostnamectl set-hostname "${hostname}"

########## CRI Prerequisites

## Forward IPv4 and let iptables see bridged traffic
# Reference: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

########## Install ContainerD
# Reference: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

## Install prerequisites
# Reference: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

# Install prerequisite packages to allow apt to use a repo over HTTPS
apt update
apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# Add Docker's official GPG key
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the Docker apt repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

# Update the apt package index
apt update

## Install ContainerD

apt install -y containerd.io

# Configure ContainerD with default config
# Reference: https://github.com/containerd/containerd/blob/main/docs/getting-started.md#customizing-containerd
containerd config default >/etc/containerd/config.toml

# Make ContainerD use the systemd cgroup driver
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd

########## Install kubeadm, kubelet and kubectl
# Reference: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl

# Install prerequisite packages
apt update
apt install -y apt-transport-https ca-certificates curl

# Download the GCP GPG key
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the K8s apt repo
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

# Install kubelet, kubeadm and kubectl
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

########## Initialize the Control Plane

if [[ $(hostname) == "control-plane" ]]; then
  kubeadm init
fi

########## Set kubeconfig for ubuntu on the Control Plane

if [[ $(hostname) == "control-plane" ]]; then
  mkdir /home/ubuntu/.kube
  cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
  chown ubuntu:ubuntu /home/ubuntu/.kube/config
fi
