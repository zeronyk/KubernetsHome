#!/bin/bash

set -eu -o pipefail # fail on error and report it, debug all lines

sudo -n true
test $? -eq 0 || exit 1 "you should have sudo privilege to run this script"

echo '\033[0;32m making all updates and adding repos'

apt-get update -y
apt-get dist-upgrade -y
# you might want to reboot now continue from here withour reboot might be bad ...

OS=xUbuntu_20.04
CRIO_VERSION=1.23



echo "\033[0;32m Assuming your desired CRIO_VERSION is $CRIO_VERSION and you operate on UBUNTU 22.04 or 20.04 "


echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"| tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"| sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -

apt update 
apt install -y cri-o cri-o-runc

echo "\033[0;32m Starting Crio services, Start Crio on startup"
systemctl enable crio.service
systemctl start crio.service
echo " \033[0;32m Install more prequisits"
apt install -y cri-tools apt-transport-https ca-certificates
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl



echo "\033[0;32m creating cgroup-file"
echo "# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.21.0
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd" | tee  cgroup-config.yaml

apt-get update && sudo apt-get upgrade
modprobe br_netfilter


echo "\033[0;32m Kubelet was installed and started check status with 'systemctl status kubelet'"
echo "\033[0;32m Join an existing cluster with by running 'kubeadm token create --print-join-command' on master node"