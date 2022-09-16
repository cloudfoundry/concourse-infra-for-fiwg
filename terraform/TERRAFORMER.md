# terraformer notes

[Terraformer](https://github.com/GoogleCloudPlatform/terraformer) has been used to aid in migrating from Cloud Foundry to LFX account.

### 1. Fresh install on macos

```
brew install terraform
brew install terraformer
brew install --cask google-cloud-sdk

# will open browser for gcloud login
gcloud auth login

# switch to a project and create `application default` login
gcloud config set project cloud-foundry-310819
gcloud auth application-default login
```
> https://cloud.google.com/sdk/auth_success
You are now authenticated with the gcloud CLI! 
The authentication flow has completed successfully. You may close this window, or check out the resources below.

`Read the warnings` associated with running `application-default login` esp. related to saving the credential file

---

### 2. Create provider.tf in desired import folder
Required for automatic download of terraform provider

```
mkdir my-project && cd my-project

echo 'provider "google" {}' > provider.tf

terraform init
```

### 2. Import with terraformer

```
terraformer import google --projects=cloud-foundry-310819 --regions=europe-west4 --resources="gke,cloudsql,networks,subnetworks,firewall,addresses,iam"
```
also see `terraformer plan`