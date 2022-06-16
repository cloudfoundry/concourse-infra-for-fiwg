# Cloud Foundry Community CI Infra

This repo holds the deployment templates used to deploy a CF community Concourse instance
and supporting infra structure. It's used for maintaining the BOSH stemcell Concourse and for the 
Application Runtime Deployments WG Concourse.

## Requirements
- gcloud => 337.0.0
- helm => 3.5.4
- vendir => 0.18
- ytt
- kapp
- jq
- kubectl

## Getting started

Authenticate to your GCP account with:
```
gcloud auth login
```

Configure the correct project and default region (will be loaded from project settings) by running:
```
gcloud init
```

Set the project region (see https://cloud.google.com/compute/docs/regions-zones):
```
PROJECT_REGION="..."
```

### Initialise new GCP projects

For new GCP projects, make sure to enable the following APIs in advance (otherwise the "init" script cannot allocate some resources):
- "Cloud Resource Manager API"
- "Secret Manager API"
- "Cloud SQL Admin API"
- "Kubernetes Engine API"
- "Identity and Access Management (IAM) API"

### Reserve load balancer IP address

First, you must reserve a static IP address for the load balancer. In the GCP console, go to:
"Networking" -> "VPC network" -> "IP addresses" -> "Reserve external static address"

Adapt the "Region", but leave everything else to the default value. When the IP address has been allocated,
copy it into [build/concourse/values.yml](build/concourse/values.yml) as `loadBalancerIP`.

For more information on allocating IPs, see https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address

### Setup infrastructure

Use the script `bin/init` to create a new Concourse cluster from scratch. The script will create a SQL instance, a GKE Kubernetes cluster,
network resources and service accounts.

### Initialise kubectl

Configure access to the GKE cluster by executing the following command:
```
PROJECT_ID=$(gcloud config get-value core/project 2>/dev/null) \
gcloud container clusters get-credentials concourse --zone ${PROJECT_REGION} --project ${PROJECT_ID}
```
Then you are able to use `kubectl` against the GKE cluster for further work. To test cluster access, you can call:
```
kubectl cluster-info
```

### Create Namespace

For the following step you need a Kubernetes namespace. Run this script once:
```
./bin/create-concourse-namespace
```

### Create GitHub OAuth application

This is necessary if you want to be able to authenticate with your GitHub profile. Log on to github.com and navigate to:
"Settings" -> "Developer settings" -> "OAuth Apps" -> "New OAuth App"

As "Homepage URL", enter the Concourse's base URL. As "Authorization callback URL", enter the Concourse URL followed
by `/sky/issuer/callback`.

When the app has been created, store its Client ID and the Client secret as Kubernetes secret:
```
ghID=paste your Client ID
ghSecret=paste your Client secret
kubectl -n concourse create secret generic github --from-literal=id=${ghID} --from-literal=secret=${ghSecret}
```

### Sync external repositories

The project uses [vendir](https://carvel.dev/vendir/) to manage external repositories. The [vendir.yml](vendir.yml) file
declares a list of repositories which are synced into the workspace:
```
./bin/sync
```

### Use Helm to generate Kubernetes deployments

First, adapt the parameters in the Concourse `values.yml` files to your project: [values.yml](build/concourse/values.yml).

You should check and adapt at least these parameters:
- concourse.web.auth.mainTeam
- concourse.web.externalUrl
- web.service.api.loadBalancerIP

Then call the `build` script which uses Helm templating and ytt to generate the Kubernetes deployments:
```
./bin/build
```

### Deploy the project to the cluster

Now you can deploy the all applications with [kapp](https://carvel.dev/kapp/):
```
./bin/deploy
```
This will deploy a CredHub instance, a UAA, the [Quarks Secret](https://quarks.suse.dev/docs/quarks-secret/) manager,
the [Cloud SQL Auth Proxy](https://cloud.google.com/sql/docs/postgres/sql-proxy) and the
[GCP Config Connector](https://cloud.google.com/config-connector/docs/how-to/getting-started). Note that the Config Connector
is used to create additional GCP service accounts.

When `deploy` has finished successfully, you should see a list of running workloads in the GCP console.

### Connect to CredHub

To spin up a pod and start a CredHub CLI session run:
```
./start-credhub-cli.sh
```

In the pod you can call:
```
credhub find
```
to see a list of all credentials (initially there are no credentials).

### Store CredHub encryption key in Google Secrets

Once deployed, we have to save CredHub encryption key to Google Secrets in case of a disaster situation.
This is to be done only on first deployment, see [docs/disaster_recovery](./docs/disaster_recovery.md) for recovery details.

```
gcloud secrets create credhub-encryption-key
kubectl get secret credhub-encryption-key -n concourse -o json | jq -r .data.password | base64 --decode | gcloud secrets versions add credhub-encryption-key --data-file=-
```

### Create hmac keys for concourse service account
```
PROJECT_ID=$(gcloud config get-value core/project 2>/dev/null) \
gsutil hmac create -p $PROJECT_ID concourse@$PROJECT_ID.iam.gserviceaccount.com
```
