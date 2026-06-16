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
