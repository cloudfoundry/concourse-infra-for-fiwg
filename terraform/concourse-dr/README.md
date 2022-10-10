# WIP
---

# DR notes

Upon recovery with terraform it might be required to import resources (depending on what has been deleted).

Scenarios assume terraform apply was run after 1st deployment from `concourse-dr` folder. 

## DR scenarios tested

Scenario A:
* deleted entrie deployment including 'concourse' namespace
* deleted all databases and database users
* GKE cluster not destroyed


TODO:
* test recovery with fresh k8s cluster

### Recovery Scenario A

1. Ensure infra part is up to scratch

Should report namespace is deleted
```
cd ./concourse-infra
terraform apply
```

2. Recreate 'backend' part.
*WARNING* proceed with caution if you use backend components in other projects on the cluster (ie. carvel secret gen).
```
cd ./concourse-backend
terraform taint carvel_kapp.concourse_backend
terraform plan
terraform apply
```

3. Restore SQL Instance from backup
* https://console.cloud.google.com/sql/instances/concourse/backups -> Restore desired backup version


4. Restore required secrets
* Edit [concourse-dr/restore.tf](concourse-dr/restore.tf) variables to indicate what to restore. 

To restore all
```
    credhub_restore_encryption_password = true
    credhub_restore_config              = true
    sql_users_restore_passwords         = true
```
Apply terraform with `terraform apply`

5. Deploy remaining components
```
cd ../concourse-app
terraform apply
```


