#!/bin/bash

# Copyright 2022 The OpenYurt Authors.
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

## configure kube-apiserver
## https://openyurt.io/zh/docs/installation/openyurt-prepare/#3-kube-apiserver%E8%B0%83%E6%95%B4

yurt_tunnel_dns_clusterip=`kubectl get svc yurt-tunnel-dns -n kube-system -o jsonpath='{.spec.clusterIP}'`

sed -i '/dnsPolicy:/d' /etc/kubernetes/manifests/kube-apiserver.yaml
sed -i '/spec:/a \ \ dnsPolicy: "None"' /etc/kubernetes/manifests/kube-apiserver.yaml

sed -i '/spec:/a \
  dnsConfig:\
    nameservers:\
    \- '${yurt_tunnel_dns_clusterip}'\
    searches:\
    \- kube-system.svc.cluster.local\
    \- svc.cluster.local\
    \- cluster.local\
    options:\
    \- name: ndots\
      value: "5"' /etc/kubernetes/manifests/kube-apiserver.yaml

sed -i 's/--kubelet-preferred-address-types=.*$/--kubelet-preferred-address-types=Hostname,InternalIP,ExternalIP/g' /etc/kubernetes/manifests/kube-apiserver.yaml