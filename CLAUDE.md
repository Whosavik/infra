This repo describes the following azure infrastructure:

- non prod AKS cluster
- prod AKS cluster
- peerings and dns resolver for AKS vnets to a central hub vnet
- namespace for argocd and ConfigMap for cluster specific configuration

This is meant to be used with OpenTofu, executed locally not via CI. Changes to this infra will be rare, as this describes only the minimal infra for a working k8s cluster. App specific infrastructure will be provisioned via gitops using ASO.

There is only one main coding principle - we have to prevent/reduce divergence of the clusters. This is accomplished by:

- defining a base cluster configuration using terraform modules
- any difference in cluster configuration must be expressed as an override on the base configuration
- if an override is not provided, it should default to the base config - this makes sure that we always converge on the base config
