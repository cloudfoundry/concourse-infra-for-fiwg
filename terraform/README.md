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

#### Apply terraform 

```
cd ../
terraform init
terraform plan
terraform apply
```
---
# Examples

### Import existing resource via Terraform

```
terraform import google_dns_managed_zone.app-runtime-interfaces projects/app-runtime-interfaces-wg/managedZones/app-runtime-interfaces           

```
