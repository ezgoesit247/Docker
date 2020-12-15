#https://computingforgeeks.com/deploy-kubernetes-cluster-on-ubuntu-with-kubeadm/

apt-get -y update && apt-get -y upgrade
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get -y update && apt-get -y upgrade
apt-get install -y kubectl
apt-get install -y kubelet
apt-get install -y kubeadm
command -v kubectl && command -v kubelet  && command -v kubeadm


echo "deb https://apt.kubernetes.io/ kubernetes-focal main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get -y update && apt-get -y upgrade
