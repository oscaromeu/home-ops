!!! tip

    If you have any doubts, please refer to the [template's documentation](https://github.com/onedr0p/flux-cluster-template). Some sections may have been replicated


## Global Cloudflare API Key

In order to use Terraform and `cert-manager` with the Cloudflare DNS challenge you will need to create a API key.

1. Head over to Cloudflare and create a API key by going [here](https://dash.cloudflare.com/profile/api-tokens).

2. Under the `API Keys` section, create a global API Key.

3. Use the API Key in the appropriate variable in configuration section below.

You may wish to update this later on to a Cloudflare **API Token** which can be scoped to certain resources. I do not recommend using a Cloudflare **API Key**, however for the purposes of this template it is easier getting started without having to define which scopes and resources are needed. For more information see the [Cloudflare docs on API Keys and Tokens](https://developers.cloudflare.com/api/).

## Configuring Cloudflare DNS with Terraform

Review the Terraform scripts under `./terraform/cloudflare/` and make sure you understand what it's doing (no really review it).

If your domain already has existing DNS records **be sure to export those DNS settings before you continue**.

1. Pull in the Terraform deps

    ```sh
    task terraform:init
    ```

2. Review the changes Terraform will make to your Cloudflare domain

    ```sh
    task terraform:plan
    ```

3. Have Terraform apply your Cloudflare settings

    ```sh
    task terraform:apply
    ```

If Terraform was ran successfully you can log into Cloudflare and validate the DNS records are present.

The cluster application [external-dns](https://github.com/kubernetes-sigs/external-dns) will be managing the rest of the DNS records you will need.

## DNS

The [external-dns](https://github.com/kubernetes-sigs/external-dns) application created in the `networking` namespace will handle creating public DNS records. By default, `echo-server` and the `flux-webhook` are the only public domain exposed on your Cloudflare domain. In order to make additional applications public you must set an ingress annotation (`external-dns.alpha.kubernetes.io/target`) like done in the `HelmRelease` for `echo-server`. You do not need to use Terraform to create additional DNS records unless you need a record outside the purposes of your Kubernetes cluster (e.g. setting up MX records).

[k8s_gateway](https://github.com/ori-edge/k8s_gateway) is deployed on the IP choosen for `${BOOTSTRAP_METALLB_K8S_GATEWAY_ADDR}`. Inorder to test DNS you can point your clients DNS to the `${BOOTSTRAP_METALLB_K8S_GATEWAY_ADDR}` IP address and load `https://hajimari.${BOOTSTRAP_CLOUDFLARE_DOMAIN}` in your browser.

You can also try debugging with the command `dig`, e.g. `dig @${BOOTSTRAP_METALLB_K8S_GATEWAY_ADDR} hajimari.${BOOTSTRAP_CLOUDFLARE_DOMAIN}` and you should get a valid answer containing your `${BOOTSTRAP_METALLB_INGRESS_ADDR}` IP address.

If your router (or Pi-Hole, Adguard Home or whatever) supports conditional DNS forwarding (also know as split-horizon DNS) you may have DNS requests for `${SECRET_DOMAIN}` only point to the  `${BOOTSTRAP_METALLB_K8S_GATEWAY_ADDR}` IP address. This will ensure only DNS requests for `${SECRET_DOMAIN}` will only get routed to your [k8s_gateway](https://github.com/ori-edge/k8s_gateway) service thus providing DNS resolution to your cluster applications/ingresses.

To access services from the outside world port forwarded `80` and `443` in your router to the `${BOOTSTRAP_METALLB_INGRESS_ADDR}` IP, in a few moments head over to your browser and you _should_ be able to access `https://echo-server.${BOOTSTRAP_CLOUDFLARE_DOMAIN}` from a device outside your LAN.

To avoid directly exposing the local cluster, Cloudflare tunnels can be used across the wide area network (WAN). The Cloudflare Operator is employed to establish these tunnels and create Cloudflare DNS entries for services you want to make publicly accessible. Cloudflare serves as a proxy to conceal your home's WAN IP address and functions as a firewall. When you are not connected to your home network, all incoming traffic to your cluster is routed through a Cloudflare tunnel.


!!! warning

    If you want to follow the cloudflare tunnel approach disable `external-dns` and `cloudflare-ddns` components in the kustomization file in the networking namespace.

### Cloudflare Operator

Follow the [getting started guide](https://github.com/adyanth/cloudflare-operator/blob/main/docs/getting-started.md) to use cloudflare operator.


!!! warning

    Notice that ExternalSecrets will try to pull the following secrets from Doppler.

    ```yaml
    # kubernetes/apps/networking/cloudflare-operator/app/externalsecrets.yaml
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: cloudflare-operator
      namespace: cloudflare-operator-system
    spec:
      secretStoreRef:
        kind: ClusterSecretStore
        name: cloudflare-operator-cluster-secret-store
      target:
        name: cloudflare-operator-secret
        creationPolicy: Owner
        template:
          engineVersion: v2
          data:
            CLOUDFLARE_API_TOKEN: "{{ .CLOUDFLARE_TOKEN }}"
            CLOUDFLARE_API_KEY: "{{ .CLOUDFLARE_APIKEY }}"

      data:
        - secretKey: CLOUDFLARE_TOKEN
          remoteRef:
            key: CLOUDFLARE_TOKEN

      - secretKey: CLOUDFLARE_APIKEY
        remoteRef:
          key: CLOUDFLARE_APIKEY
    ```
