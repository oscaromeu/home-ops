# 🏡 🧪 Home Lab

## 📖 Overview

This mono repository houses the infrastructure for my homelab. I try to adhere to Infrastructure as Code (IaC) and GitOps practices using tools like [Ansible](https://www.ansible.com/), [Terraform](https://www.terraform.io/), [Kubernetes](https://kubernetes.io/), [Flux](https://github.com/fluxcd/flux2), [Renovate](https://github.com/renovatebot/renovate) and [GitHub Actions](https://github.com/features/actions).

## ⛵ How to get started

There is a template over at [onedr0p/flux-cluster-template](https://github.com/onedr0p/flux-cluster-template) if you want to try and follow along with some of the practices I use here.

## 🎨 Cluster components

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

## 🗄️ Hardware
<details>

## Production Nodes

| Device             | Count | Specs                                                                                                                                                                                                                                                                                                          | OS                                                  | Purpose |
|--------------------|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|---------|
| MinisForum um350   | 1     | **RAM** `32GB` <br/> **M.2 SSD** `500GB` <br/> **HDD SSD** `500GB`                                                                                                                                                       | Ubuntu 22.04.4 LTS                     |  Control Plane       |
| MinisForum um350   | 1     | **RAM** `32GB` <br/> **M.2 SSD** `500GB` <br/> **HDD SSD** `500GB`                                                                                                                                                     | Ubuntu 22.04.4 LTS                       |  Data Plane       |
| Minisforum um560   | 1     | **RAM** `32GB`  <br/> **M.2 SSD** `1TB` <br/> **HDD SSD** `500GB`                                                                                                                                                    | Ubuntu 22.04.4 LTS                     |    Data Plane     |

## Staging Nodes

| Device             | Count | Specs                                                                                                                                                                                                                                                                                                          | OS                                                  | Purpose |
|--------------------|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|---------|
| Turing Pi RK1      | 3     | **RAM** `16GB` <br/> **M.2 SSD** `500GB`| Ubuntu 22.04 LTS |   Development & Staging      |

## Infrastructure

| Device             | Count | Specs                                                                                                                                                                                                                                                                                                         | OS       | Purpose |
|--------------------|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------|
| Turing Pi RK1      | 1    | **RAM** `16GB` <br/> **M.2 SSD** `500GB` <br/> **HDD** `1TB` | -  | DNS Server |
| Turing Pi Board V2 | 1     | -   |   -       |     -    |
| Unifi UDM Pro      | 1     | - | - |    10Gb Core Switch + Router + FW    |
| Unifi Lite 8 PoE     | 1     | - | - |    Switch    |
| Mac Mini     | 1     | **RAM** `8GB` <br/> **M.2 SSD** `256GB` | - |    TBD    |


</details>

</details>

## 📜 Changelog

See my _awful_ commit [main history](https://github.com/oscaromeu/home-ops/commits/main) and [legacy history](https://github.com/oscaromeu/home-ops/tree/d75a6360586de8b5b5c4ff6b553b7512cfea5007)

## :handshake:&nbsp; Gratitude and thanks

Thanks all the people of [Home Operations](https://discord.gg/home-operations) Discord community who put a lot of effort and donate their time to the community.

## 🔏 License

See [LICENSE](./LICENSE) v.g WTF License
