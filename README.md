# BOSH Community Stemcell CI Infra

This repo holds the deployment templates used to deploy the Concourse instance
and supporting infra structure used by the community maintained BOSH stemcell.

## Getting started

Configure the correct project and default region (will be loaded from project settings) by running:
```
gcloud init
```



### Rebuild infra from scratch

# TODO document creating the concourse gke cluster using the gcloud cli

#### Setting up the external Cloud Sql database



The k8s cluster is stateless meaning all components requiring persistence use a shared Cloud Sql instance.
This instace has been setup manually (using the steps documented below), and is hooked up to the components using
the [Google provided SQL Auth proxy sidecar container](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine#introduction).
