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

# create SP and assign roles
az ad sp create-for-rbac --name husavik-tofu --role Contributor \
  --scopes /subscriptions/<subscription-id>


# alternative bec bug in az cli in linux
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

### DNS

Deploys the DNS Private Resolver into your existing hub VNet and links any private DNS zones
you listed in `TF_VAR_private_dns_zone_names`.

```bash
task hub:plan
task hub:apply
```

### Step 3 — Shared (ACR)

Creates the Container Registry in `rg-shared`.

```bash
task shared:plan
task shared:apply
```

```bash
az role assignment create --assignee $APP_ID --role "User Access Administrator" --scope "/subscriptions/$SUB_ID/resourceGroups/rg-shared/providers/Microsoft.ContainerRegistry/registries/<acr-name>
```

### Deploy Clusters

Creates the resource group, VNet peering (both directions), and the AKS cluster.
The cluster's DNS is set to the resolver from step 2, and AcrPull is wired automatically.

```bash
task prod:plan
task prod:apply

task nonprod:plan
task nonprod:apply
```

## Getting kubeconfig

```bash
# Prod
az aks get-credentials --resource-group rg-prod --name aks-prod

# Nonprod
az aks get-credentials --resource-group rg-nonprod --name aks-nonprod
```

### Destroying nonprod

```bash
task nonprod:destroy
```

This only removes the nonprod cluster and its spoke VNet. The ACR, hub resolver, and prod
cluster are not affected.
