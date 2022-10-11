# WIP
---

# DR notes

Upon recovery with terraform it might be required to import resources (depending on what has been deleted).

Scenarios assume terraform apply was run after 1st deployment from `concourse-dr` folder. 

## DR scenarios tested

Scenario A:
* deleted entire deployment including 'concourse' namespace
* deleted all databases and database users
* GKE cluster not destroyed 


TODO:
* test recovery with fresh k8s cluster

### Recovery Scenario A

1. Restore SQL Instance from backup
* https://console.cloud.google.com/sql/instances/concourse/backups -> Restore desired backup version

2. Ensure infra part is up to scratch. Should report a namespace will be created.
##### Please note usage of brackets as these allow to execute bash commands from subfolders and return to the current folder once finished.
```
( cd ./concourse-infra && terragrunt apply )
```
*Note: terraform reporting missing databases at this point is an indication instance restoration needs to be run.*

2. Recreate 'backend' part.
```
( cd concourse-backend && terragrunt apply )
```

**MAINTENANCE step:** In case carvel kapp complains you can taint and reprovision.
 _WARNING_ proceed with caution if you use backend components in other projects on the cluster (ie. carvel secret gen).
```
cd ./concourse-backend
terraform taint carvel_kapp.concourse_backend
terraform plan
terraform apply
```


4. Restore secrets
```
( cd concourse-dr/restore && terraform apply )
```
*NOTE:* due to the dr recovery workflow need this part is not managed with terragrunt.

5. Deploy remaining components
From this moment onward `terragrunt` should be happy to run again as usual.

```
terragrunt run-all plan
terragrunt run-all apply
```


