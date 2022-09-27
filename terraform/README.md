# Prerequisites for a fresh project
Adjust `variables.tf`

# Logon to your GCP account

```
gcloud auth login

# switch to a project and create `application default` login
gcloud config set project <PROJECT_NAME>
gcloud auth application-default login
```

#### Create GCS bucket for terraform state
```
cd _init
terraform init
terraform apply
```


### Import existing GCP resources to terraform state

```
terraform import google_dns_managed_zone.app-runtime-interfaces projects/app-runtime-interfaces-wg/managedZones/app-runtime-interfaces
terraform import google_compute_network.vpc projects/app-runtime-interfaces-wg/global/networks/default

```


### Apply terraform for infrastructure

```
cd ../infra
terraform init
terraform plan
terraform apply
```
