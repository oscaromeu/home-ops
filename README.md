# 🏡 🧪 Home Lab

## 📖 Overview

This mono repository houses the infrastructure for my homelab. I try to adhere to Infrastructure as Code (IaC) and GitOps practices using tools like [Ansible](https://www.ansible.com/), [Terraform](https://www.terraform.io/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate) and [GitHub Actions](https://github.com/features/actions).

This project aims to achieve its goals while adhering to industry-standard best practices and fostering continuous learning.

## ⛵ Kubernetes

There is a template over at [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) if you want to try and follow along with some of the practices I use here.

## ⛵ Core Components

+ [actions-runner-controller](https://github.com/actions/actions-runner-controller): Self-hosted Github runners
+ [cert-manager](https://cert-manager.io/docs/): Creates SSL certificates for services in my k3s cluster.
+ [cilium](https://cilium.io/get-started/): Internal Kubernetes networking plugin.
+ [external-dns](https://github.com/kubernetes-sigs/external-dns): Automatically manages DNS records from my cluster in a cloud DNS provider.
+ [external-secrets](https://github.com/external-secrets/external-secrets/): Managed Kubernetes secrets using [Doppler](https://www.doppler.com).
+ [ingress-nginx](https://github.com/kubernetes/ingress-nginx/): Ingress controller to expose HTTP traffic to pods over DNS.
+ [Rook](https://rook.io): Distributed block storage for persistent storage.
+ [sops](https://github.com/mozilla/sops): Managed secrets for Kubernetes, Ansible and Terraform which are commited to Git.
+ [volsync](https://volsync.readthedocs.io/en/stable/) and [snapscheduler](https://backube.github.io/snapscheduler/): Backup and recovery of persistent volume claims.

... and more!

### Hardware

- 1 × MinisForum `um350`:
    - CPU: `Intel i5-8279U (8) @ 4.100GHz`
    - GPU: `Intel CoffeeLake-U GT3e [Iris Plus Graphics 655]`
    - RAM: `32GB`
    - M.2 SSD: `500GB`
    - HDD SSD: `500GB`

- 1 × MinisForum `um350`:
    - CPU: `AMD Ryzen 5 3550H with Radeon Vega Mobile Gfx (8) @ 2.100GHz`
    - GPU: `AMD ATI Radeon Vega Series / Radeon Vega Mobile Series`
    - RAM: `32GB`
    - M.2 SSD: `500GB`
    - HDD SSD: `500GB`

- 1 × Minisforum `um560`:
    - CPU: `AMD Ryzen 5 5600H with Radeon Graphics @ 12x 3.3GHz`
    - GPU: `AMD ATI Radeon Vega Series / Radeon Vega Mobile Series`
    - RAM: `32GB`
    - M.2 SSD: `1TB`
    - HDD SSD: `500Gb`

- 4 x Turing Pi RK1
    - CPU: `8-core (Cortex-A76x4+ Cortex-A55x4) 64-bit CPU @ 2.4 GHz`
    - GPU: `ARM Mali-G610MP4 quad-core GPU and a dedicated AI accelerator NPU`
    - NPU: `6TOPS`
    - RAM: `16Gb`
    - M.2 SSD: `500Gb`

## 📜 Changelog

See my _awful_ commit [main history](https://github.com/oscaromeu/home-ops/commits/main) and [legacy history](https://github.com/oscaromeu/home-ops/commits/feature/legacy)

## :handshake:&nbsp; Gratitude and thanks

Thanks all the people of [Home Operations](https://discord.gg/home-operations) Discord community who put a lot of effort and donate their time to the community.

---

## 🔏 License

See [LICENSE](./LICENSE) v.g WTF License
