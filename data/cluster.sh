#!/bin/bash
# Archivo plantilla para levantar y conectar el cluster
# Definición del cluster se encuentra en kind.yaml

# Login en Azure
az login --service-principal --username ${sp_id} --password ${sp_pass} --tenant ${tenant_id}
az account set --subscription ${subscription_id}

# Instalación de extensiones y proveedores
az extension add --name connectedk8s
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
az provider register --namespace Microsoft.ExtendedLocation

# Comprobación del registro
az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table
az provider show -n Microsoft.ExtendedLocation -o table

# Instalamos golang y kind para preparar el cluster
go install sigs.k8s.io/kind@latest

# Creamos el cluster 
export PATH="$HOME/go/bin:$PATH"
export KUBECONFIG="${working_dir}/kind-config"
kind create cluster --name arc-kind --config kind.yaml --kubeconfig kind-config

# Conectamos con azure 
az connectedk8s connect --name arc-kind --resource-group ${resource_group} --kube-config ${working_dir}/kind-config

# Comprocaciones finales
kubectl get deployments,pods -n azure-arc
az connectedk8s list --resource-group ${resource_group} --output table