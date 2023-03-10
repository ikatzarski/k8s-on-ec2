#!/bin/bash -x

# Disable swap
swapoff -a

# Set up hostnames
echo "
${control_plane_private_ip} ${control_plane_hostname}
${worker_1_private_ip} ${worker_1_hostname}
${worker_2_private_ip} ${worker_2_hostname}" >>/etc/hosts

# Override hostname
hostnamectl set-hostname "${hostname}"

# Update apt
apt update
