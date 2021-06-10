# BOSH Community Stemcell CI Infra

This repo holds the deployment templates used to deploy the Concourse instance
and supporting infra structure used by the community maintained BOSH stemcell.

## Requirements
- gcloud => 337.0.0
- helm => 3.5.4
- vendir => 0.18
- ytt
- kapp
- jq
- kubectl

## Getting started

Configure the correct project and default region (will be loaded from project settings) by running:
```
gcloud init
```

Configure access to the gke cluster by executing the following command:
```
PROJECT_ID=$(gcloud config get-value core/project 2>/dev/null) \
gcloud container clusters get-credentials concourse --zone europe-west4-a --project ${PROJECT_ID}
```
Then you are able to use `kubectl` against the gke cluster for further work.


### Rebuild infra from scratch

Use the script `bin/init` to create a new concourse cluster from scratch. Note you need to be logged in to gcp and set the correct project id.

### Deploy the project to the cluster
```
./bin/sync
./bin/build
./bin/deploy
```

### Connect to credhub

To spin up a pod and start a credhub-cli session run:
```
./start-credhub-cli.sh
```

### Store credhub encryption key in Google Secrets

Once deployed, we have to save credhub encryption key to Google Secrets in case of a disaster situation.
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
