#!/bin/bash -x

####################
########## VARIABLES

HOSTNAME="${hostname}"
CONTROL_PLANE_PRIVATE_IP="${control_plane_private_ip}"
CONTROL_PLANE_HOSTNAME="${control_plane_hostname}"
CONTROL_PLANE_EXPECTED_HOSTNAME="control-plane"
WORKER_1_PRIVATE_IP="${worker_1_private_ip}"
WORKER_1_HOSTNAME="${worker_1_hostname}"
WORKER_2_PRIVATE_IP="${worker_2_private_ip}"
WORKER_2_HOSTNAME="${worker_2_hostname}"

#############################
########## HOST CONFIGURATION

disable_swap() {
  swapoff -a
}

provide_hostnames_for_all_nodes() {
  echo "
$CONTROL_PLANE_PRIVATE_IP $CONTROL_PLANE_HOSTNAME
$WORKER_1_PRIVATE_IP $WORKER_1_HOSTNAME
$WORKER_2_PRIVATE_IP $WORKER_2_HOSTNAME" >>/etc/hosts
}

set_hostname() {
  hostnamectl set-hostname "$HOSTNAME"
}

SET_UP_HOST() {
  disable_swap
  provide_hostnames_for_all_nodes
  set_hostname
}

############################
########## CRI CONFIGURATION

# References:
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic
forward_ipv4_and_let_iptables_see_bridged_traffic() {
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
}

# References:
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
install_cri_prerequisites() {
  apt update
  apt install -y ca-certificates curl gnupg lsb-release
}

add_docker_gpg_key() {
  mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
}

add_docker_apt_repo() {
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt update
}

install_containerd() {
  apt install -y containerd.io
}

# References:
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
# https://github.com/containerd/containerd/blob/main/docs/getting-started.md#customizing-containerd
configure_containerd() {
  containerd config default >/etc/containerd/config.toml

  # use the systemd cgroup driver
  sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
  systemctl restart containerd
}

SET_UP_CRI() {
  forward_ipv4_and_let_iptables_see_bridged_traffic
  install_cri_prerequisites
  add_docker_gpg_key
  add_docker_apt_repo
  install_containerd
  configure_containerd
}

################################
########## KUBEADM CONFIGURATION

install_kubeadm_prerequisites() {
  apt update
  apt install -y apt-transport-https ca-certificates curl
}

add_gcp_gpg_key() {
  curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
}

add_kubernetes_apt_repo() {
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
}

install_kubelet_kubeadm_kubectl() {
  apt update
  apt install -y kubelet kubeadm kubectl
  apt-mark hold kubelet kubeadm kubectl
}

# References:
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
SET_UP_KUBEADM() {
  install_kubeadm_prerequisites
  add_gcp_gpg_key
  add_kubernetes_apt_repo
  install_kubelet_kubeadm_kubectl
}

######################################
########## CONTROL PLANE CONFIGURATION

initialize_the_control_plane() {
  kubeadm init
}

create_ubuntu_kube_config() {
  mkdir /home/ubuntu/.kube
  cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
  chown ubuntu:ubuntu /home/ubuntu/.kube/config
}

SET_UP_CONTROL_PLANE() {
  initialize_the_control_plane
  create_ubuntu_kube_config
}

############################
########## CNI CONFIGURATION

# Reference:
# https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#-installation
# Default CIDR: 10.32.0.0/12
install_weavenet_cni() {
  kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml --kubeconfig=/etc/kubernetes/admin.conf
}

SET_UP_CNI() {
  install_weavenet_cni
}

###########################
########## ADDITIONAL TOOLS

install_helm() {
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg >/dev/null
  apt install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
  apt update
  apt install helm
}

SET_UP_ADDITIONAL_TOOLS() {
  install_helm
}

#####################
########## FULL SETUP

SET_UP_HOST
SET_UP_CRI
SET_UP_KUBEADM

if [[ $(hostname) == "$CONTROL_PLANE_EXPECTED_HOSTNAME" ]]; then
  SET_UP_CONTROL_PLANE
  SET_UP_CNI
  SET_UP_ADDITIONAL_TOOLS
fi
