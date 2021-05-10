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



### Rebuild infra from scratch


#### setup postgres
if there are no passwords created for the postgresl admin password
you can check this with `gcloud secrets versions list postgres-admin` if not follow the commands below.
```
gcloud secrets create postgres-admin
openssl rand -base64 14 | gcloud secrets versions add postgres-admin --data-file=-
```
build postgres instance
```
gcloud sql instances create concourse \
    --database-version=POSTGRES_13 \
    --availability-type=regional \
    --region=$(gcloud config get-value compute/region 2>/dev/null) \
    --cpu=1 --memory=4 \
    --enable-point-in-time-recovery \
    --root-password=$(gcloud secrets versions access $(gcloud --format=json secrets versions list postgres-admin | jq -r 'map(select(.state == "ENABLED"))[0].name'))
```

create databases on sql instance
```
for ds in concourse credhub uaa; do \
gcloud sql databases create $ds --instance concourse; \
done
```

#### build gke
```
PROJECT_ID=$(gcloud config get-value core/project 2>/dev/null)
gcloud container clusters create concourse \
    --release-channel regular \
    --addons ConfigConnector \
    --workload-pool=${PROJECT_ID}.svc.id.goog \
    --enable-stackdriver-kubernetes \
    --region europe-west4-a \
    --enable-autoscaling --max-nodes=6 --min-nodes=4
```
TODO: --cluster-ipv4-cidr

create _concourse_ namespace
Created outside of kapp so that kapp can store its metadata inside the _concourse_ namespace
TODO: change namespace setting in bin/deploy before recreting the cluster
```
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: concourse
  labels:
    quarks.cloudfoundry.org/monitored: concourse
EOF
```

#### config connector
setup service accounts
gcloud iam service-accounts create cnrm-system
Bind the roles/owner to the service account:
```
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/owner"
```
Bind roles/iam.workloadIdentityUser to the cnrm-controller-manager Kubernetes Service Account in the cnrm-system Namespace:
```
gcloud iam service-accounts add-iam-policy-binding \
cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com \
  --member="serviceAccount:${PROJECT_ID}.svc.id.goog[cnrm-system/cnrm-controller-manager]" \
  --role="roles/iam.workloadIdentityUser"
```

# TODO document creating the concourse gke cluster using the gcloud cli

#### Setting up the external Cloud Sql database



The k8s cluster is stateless meaning all components requiring persistence use a shared Cloud Sql instance.
This instace has been setup manually (using the steps documented below), and is hooked up to the components using
the [Google provided SQL Auth proxy sidecar container](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine#introduction).
