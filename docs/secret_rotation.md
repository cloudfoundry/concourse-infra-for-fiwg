# Secret Rotation

To rotate secrets set the "rotate_quark_secrets" property to true in config/values/00-values.yml file:
```
rotate_quark_secrets: true
```
and run:
```
./bin/deploy
```

This will deploy a ConfigMap which triggers QuarksSecrets CRD controller to rotate secretes defined in the config map, see config/quarks-secret/secret-rotation.yml file for details.

Tail the logs of the QuarksSecrets CRD controller to know when the rotation is done (errors in the log can be ignored).
Once finished, we need to update database passwords and restart pods for the changes to take effect:

Update database password:
```
for user in concourse credhub uaa; do \
  pass=$(kubectl -n concourse get secret "$user-postgresql-password" -o json | jq -r .data.password | base64 --decode); \
  gcloud sql users set-password "$user" -i concourse --password="$pass";\
done
```

Recreate all pods:
```
kubectl -n concourse delete pod -l app=uaa-deployment
kubectl -n concourse delete pod -l app=credhub
kubectl -n concourse delete pod -l app=concourse-web
kubectl -n concourse delete pod -l app=concourse-worker
```
