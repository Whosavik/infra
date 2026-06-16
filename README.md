# AKS Infrastructure

## Architecture

State is stored in Azure Blob Storage, split by module:
`hub/terraform.tfstate`, `shared/terraform.tfstate`, `prod/terraform.tfstate`, `nonprod/terraform.tfstate`

## Prerequisites

| Tool | Install |
|---|---|
| OpenTofu >= 1.6 | <https://opentofu.org/docs/intro/install/> |
| Task | <https://taskfile.dev/installation/> |
| Azure CLI | <https://learn.microsoft.com/en-us/cli/azure/install-azure-cli> |

## First-time setup

```bash

SUB_ID=$(az account list --query [0].id --out tsv)
TENANT_ID=$(az account list --query [0].tenantId --out tsv)
APP_ID=$(az ad app create --display-name infra-tofu --query appId -o tsv)
az ad sp create --id $APP_ID
PASS=$(az ad app credential reset --id $APP_ID --query password -o tsv)
az role assignment create --assignee $APP_ID --role Contributor --scope "/subscriptions/$SUB_ID"
az role assignment create --assignee $APP_ID --role "Network Contributor" --scope "/subscriptions/$SUB_ID/resourceGroups/cc-rg-hub"

# create tfstate storage account
az group create --name cc-rg-infra --location australiasoutheast
az storage account create \
    --name ccinfrastatee550f \
    --resource-group cc-rg-infra \
    --location australiasoutheast \
    --sku Standard_LRS \
    --min-tls-version TLS1_2

az storage container create \
    --name tfstate \
    --account-name ccinfrastatee550f

echo "
ARM_SUBSCRIPTION_ID=$SUB_ID
ARM_TENANT_ID=$TENANT_ID
ARM_CLIENT_ID=$APP_ID
ARM_CLIENT_SECRET=$PASS
BACKEND_SA=ccinfrastate
"
```

Populate the .env file.

## Provisioning

Provision everything.

```bash
task up
```

This will fail on the first run, because our identity doesn't have role assignment right to the whole subscription. So we'll need to run these when it fails:

```bash
az role assignment create --assignee $APP_ID --role "User Access Administrator" --scope "/subscriptions/$SUB_ID/resourceGroups/rg-shared
az role assignment create --assignee $APP_ID --role "User Access Administrator" --scope "/subscriptions/$SUB_ID/resourceGroups/cc-rg-prod
az role assignment create --assignee $APP_ID --role "User Access Administrator" --scope "/subscriptions/$SUB_ID/resourceGroups/cc-rg-nonprod
```

## Getting kubeconfig

```bash
# Prod
az aks get-credentials --resource-group cc-rg-prod --name aks-prod

# Nonprod
az aks get-credentials --resource-group cc-rg-nonprod --name aks-nonprod
```

### Destroying nonprod

```bash
task nonprod:destroy
```

This only removes the nonprod cluster and its spoke VNet. The ACR, hub resolver, and prod
cluster are not affected.

## Remote access via WireGuard

Both spoke clusters have no public IPs. A small VM in the hub VNet (`task hub:apply`) terminates
a WireGuard tunnel and routes into the hub, prod, and nonprod VNets, so it doubles as your way in.

Terraform doesn't generate the keys — generate them yourself and put them in `.env`:

```bash
# Server keypair — the private key goes into .env (TF_VAR_wg_server_private_key).
# The public key isn't needed by Terraform; you can discard it.
wg genkey | tee wg-server-private.key | wg pubkey > wg-server-public.key

# Client (your laptop) keypair — the private key stays on your laptop only.
# The public key goes into .env (TF_VAR_wg_client_public_key).
wg genkey | tee wg-client-private.key | wg pubkey > wg-client-public.key
```

Fill in `TF_VAR_hub_wireguard_subnet_prefix`, `TF_VAR_admin_ssh_public_key`, `TF_VAR_wg_tunnel_cidr`,
`TF_VAR_wg_server_private_key`, `TF_VAR_wg_client_public_key`, and `TF_VAR_wg_client_tunnel_ip` in
`.env` (see `.env.example`), then:

```bash
task hub:apply
task nonprod:apply   # and/or task prod:apply — adds the return route for each spoke
```

Get the VM's public key and endpoint, then bring up the tunnel from your laptop:

```bash
ssh azureuser@$(cd hub && tofu output -raw wireguard_vm_public_ip) sudo wg show wg0 public-key
```

Client `wg0.conf`:

```ini
[Interface]
PrivateKey = <contents of wg-client-private.key>
Address = <TF_VAR_wg_client_tunnel_ip without the /32, e.g. 10.200.0.2/32>

[Peer]
PublicKey = <public key printed by the ssh command above>
Endpoint = <tofu output -raw wireguard_vm_public_ip (hub)>:51820
AllowedIPs = <TF_VAR_wg_tunnel_cidr>,<TF_VAR_prod_vnet_address_space>,<TF_VAR_nonprod_vnet_address_space>
PersistentKeepalive = 25
```

```bash
wg-quick up ./wg0.conf
```
