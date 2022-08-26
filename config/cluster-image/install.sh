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

echo "[INFO] Start installing OpenYurt"

echo "[INFO] Setup flannel"
kubectl apply -f manifests/kube-flannel.yaml

echo "[INFO] Setup yurt-controller-manager"
kubectl apply -f manifests/yurt-controller-manager.yaml

echo "[INFO] Setup yurt-tunnel"
kubectl apply -f manifests/yurt-tunnel-server.yaml
kubectl apply -f manifests/yurt-tunnel-agent.yaml
kubectl apply -f manifests/yurt-tunnel-dns.yaml

echo "[INFO] Setup yurt-app-manager"
kubectl apply -f manifests/all_in_one.yaml

echo "[INFO] Setup Yurthub Settings"
kubectl apply -f manifests/yurthub-cfg.yaml

echo "[INFO] Adjust coreDNS"
kubectl apply -f manifests/coredns.yaml
kubectl scale --replicas=0 deployment/coredns -n kube-system
kubectl annotate svc kube-dns -n kube-system openyurt.io/topologyKeys='openyurt.io/nodepool'

echo "[INFO] Adjust kube-proxy"
kubectl get cm -n kube-system kube-proxy -oyaml | sed 's|kubeconfig: \/var\/lib\/kube-proxy\/kubeconfig.conf|#kubeconfig: \/var\/lib\/kube-proxy\/kubeconfig.conf|g' - | kubectl apply -f -

echo "[INFO] Adjust kube-controller-manager"
./kube-controller-manager.sh

echo "[INFO] Adjust kube-apiserver"
./kube-apiserver.sh

echo "[INFO] OpenYurt is successfully installed"