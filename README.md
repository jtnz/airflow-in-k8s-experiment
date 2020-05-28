# Airflow on k8s experiment
This experiment is to get [airflow](https://github.com/apache/airflow) running on k8s, and executing dags using the KubernetesExecutor.

## Local setup
### DNS
Get yourself setup with local DNS resolution for `*.local` to `127.0.0.1`.

### Tools
Make sure you have up to date tools. You'll need:
- `k3d`
- `kubectl`
- `helm`

### Helm chart
Get/update the Bitnami chart repo:
```shell
helm repo list | grep -q bitnami || helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Clone this repo
```shell
git clone https://github.com/jtnz/airflow-in-k8s-experiment.git
cd airflow-in-k8s-experiment
```

## Create k8s cluster
```shell
k3d create --name airflow --publish 80:80 --enable-registry --registry-name registry.local

export KUBECONFIG="$(k3d get-kubeconfig --name='airflow')"
kubectl cluster-info
```

```shell
# Wait until pods appear and are Running/Completed and READY
watch kubectl get pods -A
# C-c
```

## Create airflow namespace
```shell
kubectl apply -f ns-airflow.yaml
```

## Install Postgres and setup airflow database
```shell
helm upgrade airflow bitnami/postgresql --install --namespace airflow
watch kubectl -nairflow get pods
# Wait until airflow-postgresql-0 is ready
# C-c

export POSTGRES_PASSWORD=$(kubectl get secret --namespace airflow airflow-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
kubectl port-forward --namespace airflow svc/airflow-postgresql 5432:5432 &
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
```

```sql
CREATE DATABASE airflow;
CREATE USER airflow;
ALTER ROLE airflow WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;
ALTER DATABASE airflow OWNER TO airflow;
\q
```

```shell
fg
# C-c
```

## Build our images and push ready for k8s
```shell
./dkr_b_and_p.sh
```

## Run localstack for local S3
```shell
kubectl apply -f localstack.yaml
watch kubectl -nairflow get pods
# Wait until the localstack pod is ready
```

## Apply airflow k8s resources
Note: don't run the DAG(s) yet!
```shell
kubectl apply -f configmap.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
kubectl apply -f rbac.yaml
kubectl apply -f deployment.yaml
```

Now visit [airflow](http://airflow.local/admin/).

## Create S3 connection in airflow
- Admin > Connections > Create
- Conn Id: `localstack_s3`
- Conn Type: `S3`
- Extra: `{"host": "http://localstack:4566","aws_access_key_id":"123", "aws_secret_access_key": "abc"}`

## Test DAG
You can now run the DAG(s).

## Tear down
```shell
k3d delete --name airflow
```

## TODO
- document .local DNS resolution
- ~dags in image~
- ~start a pod for dag~
- ~pod image?~
- ~dags from git~
- ~logs in UI~
- convert this to a script to start it all
- generate airflow db user password
- separate namespaces for airflow webserver/scheduler and pods running as part of dags?
- connection setup (s3)
- ~s3 bucket setup (airflow)~
