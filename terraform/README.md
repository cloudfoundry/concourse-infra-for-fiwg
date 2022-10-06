
## Requirements
* glcoud => 403.0.0
* helm => 3.10.0
* terraform => 1.3.1
* terragrunt => 0.39.0
* kapp => 0.53.0
* ytt =>  0.43.0
* vendir => 0.31.0
* kubectl => 1.23
* jq (if needed for other scripts ie. disaster recovery tasks, currently not in use)



# Prerequisites for a fresh project
Adjust `variables.tf`

Alternatively pass as env variables or vars files to terraform / terragrunt
#### Logon to your GCP account

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


### Apply terrgrunt for infrastructure

```
cd ..
terragrunt run-all plan
terragrunt run-all apply
```
### Obtain GKE credentials
( pending automation with tf )
```
> gcloud container clusters list
NAME   LOCATION        MASTER_VERSION   MASTER_IP     MACHINE_TYPE   NODE_VERSION     NUM_NODES  STATUS
wg-ci  europe-west3-a  1.23.8-gke.1900  34.159.31.85  e2-standard-4  1.23.8-gke.1900  3          RUNNING

> gcloud container clusters get-credentials wg-ci --zone europe-west3-a
Fetching cluster endpoint and auth data.
kubeconfig entry generated for wg-ci.

❯ kubectl config current-context
gke_app-runtime-interfaces-wg_europe-west3-a_wg-ci
```


#### Manually provide Github OAuth token as k8s secret
This is necessary if you want to be able to authenticate with your GitHub profile. Log on to github.com and navigate to:
"Settings" -> "Developer settings" -> "OAuth Apps" -> "New OAuth App"

As "Homepage URL", enter the Concourse's base URL. As "Authorization callback URL", enter the Concourse URL followed
by `/sky/issuer/callback`.

Terraform will provision github secret on GCP without no version (no data) during concourse-infra stage.
Please create a version for it using gcloud command or webui, using k-v format

```
id: paste your Client ID
secret: paste your Client secret
```
Terraform fail for concourse-app if no github secret version is be present. Please rerun after version is created.
This problem occurs only when provisioning for the 1st time

More of automation can be achieved here ie. with syncing the secret directly from Vault.

### Sync exernal repositories
You might wish to bump versions of software in [vendir.yml](vendir.yml) file
```
vendir sync
```
## Execute terragrunt / terraform
Since the stack contains separately managed infra, backend and app it would require user to `cd` into each module directory and execute terraform from there.

To simplify this we use [terragrunt](https://terragrunt.gruntwork.io/) (with most basic functionality for now).


#### Manage the entire stack
```
# view incoming changes (if any)
terragrunt run-all plan

# execute changes
terragrunt run-all apply
```


# Upgrade components managed by kapp
Required actions:
* changing charts versions
* `vendir sync`

Build lifecyce:
* managed by terraform.
* able to destroy/redeploy concourse app and corresponding 'backend' components separately

# Other matters
### Store CredHub encryption key
TBD. DR scenario requirement
#### Create hmac keys for concourse service account
TBD. Currently not required.

#### Secret rotation
Quark Secrets have been dropped.
* TBD process with Carvel Secret Manager
* TBD SQL users password update - might not be an issue due to the separation of concourse backend and app.