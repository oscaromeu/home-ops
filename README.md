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

### GitOps

[Flux](https://github.com/fluxcd/flux2) watches the clusters in my [kubernetes](./kubernetes/) folder (see Directories below) and makes the changes to my clusters based on the state of my Git repository.

The way Flux works for me here is it will recursively search the `kubernetes/${cluster}/apps` folder until it finds the most top level `kustomization.yaml` per directory and then apply all the resources listed in it. That aforementioned `kustomization.yaml` will generally only have a namespace resource and one or many Flux kustomizations (`ks.yaml`). Under the control of those Flux kustomizations there will be a `HelmRelease` or other resources related to the application which will be applied.

[Renovate](https://github.com/renovatebot/renovate) watches my **entire** repository looking for dependency updates, when they are found a PR is automatically created. When some PRs are merged Flux applies the changes to my cluster.

### Directories

This Git repository contains the following directories under [Kubernetes](./kubernetes/).

```sh
📁 kubernetes            # main cluster
    ├── 📁 apps           # applications
    ├── 📁 bootstrap      # bootstrap procedures
    ├── 📁 flux           # core flux configuration
    └── 📁 templates      # re-useable components
```

### Flux Workflow

TBD

### Networking

TBD

## ☁️ Cloud Dependencies

While most of my infrastructure and workloads are self-hosted I do rely upon the cloud for certain key parts of my setup. This saves me from having to worry about two things. (1) Dealing with chicken/egg scenarios and (2) maintaining another cluster and monitoring another group of workloads for critical data services I critically need is a lot more time and effort than I am willing to put in. (3) The methodology I adhere to involves a stateless cluster, enabling me to reconstruct the cluster at my discretion, complete with all the data prepped and ready for use.

| Service                                         | Use                                                               | Cost           |
|-------------------------------------------------|-------------------------------------------------------------------|----------------|
| [Cloudflare](https://www.cloudflare.com/)       | Domain                                                            | ~€45/yr        |
| [Doppler](https://doppler.com/)                 | Secrets with [External Secrets](https://external-secrets.io/)     | 0€/yr          |
| [GCP](https://cloud.google.com/)                | Postgres Database for critical workloads                          | ~€120/yr       |
| [GitHub](https://github.com/)                   | Hosting this repository and continuous integration/deployments    | Free           |
| [Migadu](https://migadu.com/)*                  | Email hosting                                                     | ~€20/yr        |
| [NextDNS](https://nextdns.io/)*                 | My router DNS server which includes AdBlocking                    | ~€20/yr        |
| [Pushover](https://pushover.net/)               | Kubernetes Alerts and application notifications                   | €5 OTP         |
| [UptimeRobot](https://uptimerobot.com/)*        | Monitoring internet connectivity and external facing applications | ~€60/yr        |

*TBD

## 🌐 DNS

### Home DNS

TBD

### Public DNS

Outside the `external-dns` instance mentioned above another instance is deployed in my cluster and configured to sync DNS records to [Cloudflare](https://www.cloudflare.com/). The only ingress this `external-dns` instance looks at to gather DNS records to put in `Cloudflare` are ones that have an ingress class name of `external` and contain an ingress annotation `external-dns.alpha.kubernetes.io/target`.

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

Thanks all the people of [Home Operations](https://discord.gg/home-operations) Discord community who put a lot of effort and donate their time to the community. This people don't mess around, seriously. If there's something you want to learn, take a look. It will blow your mind.

---

## 🔏 License

See [LICENSE](./LICENSE) v.g WTF License
