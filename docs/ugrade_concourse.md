# How to upgrade Concourse

## Prerequiestis
- `gcloud auth login`
- `gcloud container clusters get-credentials concourse --zone europe-west4-a --project cloud-foundry-310819`

### Pre-Check
- check the version of the concourse chart we are currently on in the [vendir.yml](../vendir.yml)
- check the concourse chart release at https://github.com/concourse/concourse-chart/releases


### Upgrade
- bump concourse-chart version in the [vendir.yml](../vendir.yml)
- run `./bin/sync` this will the download the latest chart and add it to the repo
- run `./bin/build` this will build the helm chart and create the proper configs
- go trough the commits and check if there are important changes that needs our attention
- check in https://bosh.ci.cloudfoundry.org/ if there are no running builds. as an upgrade will kill those builds
- run `./bin/deploy`
- commit to git `git push`
