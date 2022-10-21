# Disaster recovery

Credhub encrypts secrets before storing them in a database.
In case of a DR situation, credhub encryption key has to restored from GCP Secret Manager before credhub can read data from its database. See [README](../README.md) for more details about preserving the credhub encryption key in GCP.

## Restore Credhub encryption key from Google Secrets

Credhub encryption key is configured in two places:
- credhub-encryption-key secret
- credhub-config secret

### credhub-encryption-key

```
enc_key=$(gcloud secrets versions access 1 --secret credhub-encryption-key | base64 -w 0)
kubectl -n concourse patch secret credhub-encryption-key -p="{\"data\":{\"password\": \"$enc_key\"}}"
```

### Github config
```
ghID=paste your github oauth id from your org
ghSecret=paste your github oauth secret from your org
kubectl -n concourse create secret generic github --from-literal=id=${ghID} --from-literal=secret=${ghSecret}
```

### credhub-config
####not sure if this is stil neccary

Get the original config yaml and save it to a temp file:
```
  kubectl -n concourse get secret credhub-config -o json | jq -r '.data["application.yml"]' | base64 --decode > tmp.yml
```

Replace encryption.providers[0].keys[0].encryption_password in tmp.yml to match the one from Google Secrets:
```
gcloud secrets versions access 1 --secret credhub-encryption-key
```

Obtain base64 encoded contents of the credhub-config secret and modify the secret:
```
cat tmp.yml | base64 | pbcopy
kubectl edit secret credhub-config
```

Paste the contents from the clipboard and save the changes.
Once both secrets have been modified, delete the credhub pod for the changes to propagate. Verify newly started credhub pod can read its database by tailing the log.

## SQL users password update

There is an issue with [Config Connector](https://cloud.google.com/config-connector/docs/overview), when concourse/uaa/credhub are redeployed from scratch, SQL user passwords are not updated and pods cannot connect to their databases. In such situation update the passwords by running the script below:
```
for user in concourse credhub uaa; do \
  pass=$(kubectl -n concourse get secret "$user-postgresql-password" -o json | jq -r .data.password | base64 --decode); \
  gcloud sql users set-password "$user" -i concourse --password="$pass";\
done
```