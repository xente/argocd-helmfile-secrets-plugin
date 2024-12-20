# argocd-helmfile-secrets-plugin

A plugin for [Argo CD](https://argoproj.github.io/argo-cd/) that integrates Helmfile and supports managing secrets in a secure and streamlined way. This plugin helps automate the process of deploying Helm charts with secret management in a GitOps workflow, enabling seamless integration of Helmfile with Argo CD for secure, declarative application delivery.

## Features

- **Seamless Integration with Argo CD**: Manage Helm releases and configurations directly from Argo CD with support for Helmfile's multi-environment capabilities.
- **Secret Management**: Securely handle cloud secrets using `vals`.
- **Declarative GitOps Workflow**: Leverage GitOps principles to manage Helmfile configurations and associated secrets.
- **Simplified Helmfile Handling**: Eliminate the need for manual Helmfile management; automate the deployment of Helm charts across multiple environments directly within Argo CD.
- **Customizable Secret Backends**: Support for multiple secret backends like `sops`, `HashiCorp Vault`, `AWS SSM Parameter Store`, `Azure Key Vault` and [others] (https://github.com/helmfile/vals).
- **Helmfile Project Selector**: Select specific Helmfile projects for deployment, allowing for granular control over which charts are managed by Argo CD.

## Requirements

- [Argo CD](https://argoproj.github.io/argo-cd/)
- [Helmfile](https://github.com/roboll/helmfile)
- Secret management backend like [SOPS](https://github.com/mozilla/sops), [Vault](https://www.vaultproject.io/), or others.

## Installation

To install the `argocd-helmfile-secrets-plugin`, follow these steps:

> We are using namespace called ArgoCD. If your ArgoCD is installed in another namespace you have to update the script

1. Create k8s configmap that's contains the command to run Helmfile.
```bash
kubectl apply -n argocd -f cmp-helmfile-configmap.yaml
```
2. Apply path script to Arg CD repo server
```bash
kubectl -n argocd patch deployments/argocd-repo-server --patch-file argocd-repo-server-patch.yaml
````
## Usage

Create your argoCD application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helmfile-demo
  namespace: argocd
spec:
  destination:
    name: in-cluster
    namespace: demo
  project: default
  source:
    path: ***Path to your helmfile***
    repoURL: ***Repo URL of the helmfile***
    targetRevision: ***Revison (branch, commit or tag)***
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

This application will be apply the helmfile to the target namespace.

For use Helmfile environments add environment variable called `HELM_ENVIRONMENT` into plugin section of your Argo CD application definition. The value of HELM_ENVIRONMENT has to be the equals to the environment name defined into the Helmfile.

For exaplme if your helmfile has environment named `dev`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helmfile-demo
  namespace: argocd
spec:
  destination:
    name: in-cluster
    namespace: demo
  project: default
  source:
    path: ***Path to your helmfile***
    repoURL: ***Repo URL of the helmfile***
    targetRevision: ***Revison (branch, commit or tag)***
    plugin:
      env:
        - name: HELM_ENVIRONMENT
          value: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

For secret use you have to add your secrets inside helmfile secret section with vals format. Please reado the [vals documentation](https://github.com/helmfile/vals)  for more details.

## Custom Image
 This plugin use docker hub public image. You can create your ouwn image using the Dockerfile of the repo and store it into your private registry. 

 When your image will be generated and puglished you have to modify argocd-repo-server-patch.yaml image.
