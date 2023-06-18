# 🏡 🧪 Home Lab

Project status: _BETA_ (but pretty stable).

## 📖 Overview

This mono repository houses the infrastructure for my homelab. I try to adhere to Infrastructure as Code (IaC) and GitOps practices using tools like [Ansible](https://www.ansible.com/), [Terraform](https://www.terraform.io/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate) and [GitHub Actions](https://github.com/features/actions).

This project aims to achieve its goals while adhering to industry-standard practices and fostering continuous learning.

## ⛵ Core Components

+ [actions-runner-controller](https://github.com/actions/actions-runner-controller): Self-hosted Github runners
+ [cert-manager](https://cert-manager.io/docs/): Creates SSL certificates for services in my k3s cluster.
+ [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records from my cluster in a cloud DNS provider.
+ [external-secrets](https://github.com/external-secrets/external-secrets/): Managed Kubernetes secrets using [Doppler](https://www.doppler.com).
+ [cilium](https://cilium.io/get-started/): Internal Kubernetes networking plugin.
+ [ingress-nginx](https://github.com/kubernetes/ingress-nginx/): Ingress controller to expose HTTP traffic to pods over DNS.
+ [longhorn](https://longhorn.io): Distributed block storage for persistent storage.
+ [sops](https://github.com/mozilla/sops)
+ [tf-controller](https://github.com/weaveworks/tf-controller): Additional Flux component used to run Terraform from within a Kubernetes Cluster.
+ [velero](https://velero.io): Backup and restore, perform disaster recovery, and migrate Kubernetes cluster resources and persistent volumes.

### Hardware

- 2 × MinisForum `um350`:
    - CPU: `AMD Ryzen 5 3550H`
    - RAM: `32GB`
    - SSD: `512GB`
- 1 × Vant `moove15`:
    - CPU: `Intel Core i7-1255u`
    - RAM: `16GB`
    - SSD: `512GB`
- 1 x Raspberry pi
    - CPU: `ARM Cortex-A72 processor`
    - RAM: `8GB`
    - NVME: `1TB`
- 3 x Raspberry pi
    - CPU: `ARM Cortex-A72 processor`
    - RAM: `4GB`
    - SD: `64GB`

### 🚧 Features

- [x] Automated Kubernetes installation and management
- [x] Installing and managing applications using GitOps
- [x] Automatic rolling upgrade for OS and Kubernetes
- [x] Automatically update apps (with approval)
- [x] Modular architecture, easy to add or remove features/components
- [x] Automated certificate management
- [x] Automatically update DNS records for exposed services
- [x] Expose services to the internet securely with [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/)
- [x] Distributed storage
- [x] Datascience jupyterhub environments
- [x] Monitoring and alerting 🚧

## 📜 Changelog

See my _awful_ commit [main history](https://github.com/oscaromeu/home-ops/commits/main) and [legacy history](https://github.com/oscaromeu/home-ops/commits/feature/legacy)

## :handshake:&nbsp; Gratitude and thanks

There is a template over at [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) if you wanted to try and follow along with some of the practices I used here.

Also, a lot of inspiration for this repo came from the following people:

- [onedr0p/home-cluster](https://github.com/onedr0p/home-cluster)
- [danmanners/homelab-kube-cluster](https://github.com/danmanners/homelab-kube-cluster)
- [billimek/k8s-gitops](https://github.com/billimek/k8s-gitops)
- [khuedoan/homelab](https://github.com/khuedoan/homelab)
- [bjw-s/k8s-gitops](https://github.com/bjw-s/k8s-gitops)
- [ricsanfre/pi-cluster](https://github.com/ricsanfre/pi-cluster)


## Community

There is a k8s@home [Discord](https://discord.gg/7PbmHRK) for this community.
