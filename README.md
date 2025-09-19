# Test de Azure Arc
Este repositorio es una prueba de la solución híbrida para gestionar clusters de Kubernetes On-Premise
# Funcionamiento
1. En los ficheros de terraform se levanta una VM en Azure como ejemplo de una máquina on-premise. 
2. Dentro de AzureAD se crean los recursos necesarios para poder permitir la conexión desde la VM.
3. Se instalan las dependencias neceisaria en la VM y se levanta un cluster de prueba a través de Kind
4. Se conecta mediante la AZ CLI el cluster creado
# Requisitos
- Una subscripción de Azure
- Identidad o Service Principal
- AZ CLI
- La extensión connectedk8s de AZ CLI
- Registro con los proveedores (Microsoft.Kubernetes, Microsoft.KubernetesConfiguration, Microsoft.ExtendedLocation)
- Un cluster de Kubernetes en funcionamiento
- Un archivo de KubeConfig que apunte a dicho cluster
- Para poder ver los recursos en el Azure Porta hace falta un service account token