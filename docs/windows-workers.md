# Windows Workers
see PR https://github.com/concourse/concourse-chart/pull/317

a new concourse version bump (with vendir) wil override our changes made in the following files
`./build/concourse/_vendir/templates/_helpers.tpl`
`./build/concourse/_vendir/templates/windows-worker-deloyment.yml`
`./build/concourse/_vendir/templates/windows-worker-statefullset.yml`
`./build/concourse/_vendir/values.yml`

## how to create a windows docker container.

create a windows server
see https://cloud.google.com/compute/docs/create-windows-server-vm-instance
select:
  Machine type: `e2-micro`
  operating system: `Windows Server`
  Version: `Windows Server 2019 DataCenter Core for Containers`

connecto the vm with rdp also state in the above url

we currently we use the foundationalinfrastructure account
https://hub.docker.com/repository/docker/foundationalinfrastructure/concourse-windows

DockerFile

```
# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019 as download

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV CONCOURSE_VERSION="7.8.3"

# Download file
RUN Invoke-WebRequest ('https://github.com/concourse/concourse/releases/download/v{0}/concourse-{0}-windows-amd64.zip' -f $env:CONCOURSE_VERSION) -OutFile 'concourse.zip' -UseBasicParsing ; `
    Expand-Archive concourse.zip -DestinationPath C:\ ; `
    Remove-Item -Path concourse.zip

# clean env
FROM mcr.microsoft.com/windows/servercore:ltsc2019

COPY --from=download C:\concourse\bin\concourse.exe /concourse.exe


ENTRYPOINT ["\\concourse.exe"]
```
docker build -t foundationalinfrastructure/concourse-windows
docker push foundationalinfrastructure/concourse-windows

## configure concourse for the windows docker container
### create a windows gke node
export the proper enviorment variables e.g.
```
export PROJECT_ID=$(gcloud config get-value core/project 2>/dev/null)
export CONCOURSE_SA=concourse
export CNRM_SA=cnrm-system
export CLUSTER_NAME=concourse
export PROJECT_REGION=europe-west4-a
```
```
gcloud container node-pools create concourse-windows-workers \
  --cluster=$CLUSTER_NAME \
  --machine-type=n1-standard-4 \
  --image-type=WINDOWS_LTSC_CONTAINERD \
  --enable-autoscaling \
  --enable-autoupgrade \
  --num-nodes=1 \
  --min-nodes=1 \
  --max-nodes=2 \
  --local-ssd-count 1 \
  --region "$PROJECT_REGION" \
  --tags=workers \
  --node-taints=workers=true:NoSchedule \
  --service-account=${CONCOURSE_SA}@${PROJECT_ID}.iam.gserviceaccount.com
```

## concourse hel chart configuration
add the following to ./build/concourse/values.yml
```
windows_worker:
  enabled: true
  replicas: 1
  tolerations:
    - key: "workers"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"
    - key: "node.kubernetes.io/os"
      operator: "Equal"
      value: "windows"
      effect: "NoSchedule"
  kind: Deployment
  nodeSelector:
    cloud.google.com/gke-local-ssd: "true"
    cloud.google.com/gke-nodepool: "concourse-windows-workers"
  resources:
    requests:
      cpu: "3000m"
```

add the following to ./build/concourse/scrub_default_creds.yml
```
#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "concourse-windows-worker"}})
---
spec:
  template:
    spec:
      #@overlay/match by=overlay.subset(None),expects="0+"
      #@overlay/remove
      initContainers:
```