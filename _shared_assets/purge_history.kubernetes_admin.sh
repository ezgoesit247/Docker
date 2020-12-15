#!/bin/bash

if [ -f /root/bash_history/kubernetes_admin.history ]; then
echo >> ~/bash_history/kubernetes_admin.history
date >> ~/bash_history/kubernetes_admin.history
cat ~/.bash_history >> ~/bash_history/kubernetes_admin.history
>.bash_history; else
echo "Error: kubernetes_admin.history not found..."
echo "       Is /root/bash_history a vmap?"

 fi
