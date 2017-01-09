# About

This image contains an installation MySQL 5.x.

For more information, see the
[Official Image Launcher Page](http://cloud.google.com/launcher/details/google/mysql5).

Pull command:
```shell
gcloud docker -- pull launcher.gcr.io/google/mysql5
```

[Dockerfile](https://github.com/GoogleCloudPlatform/mysql-docker/tree/master/5.7)

# Running MySQL server

This section describes how to spin up a MySQL service using this image.

## Start a MySQL instance

To deploy to your Kubernetes cluster, copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-mysql
  labels:
    name: some-mysql
spec:
  containers:
    - image: launcher.gcr.io/google/mysql5
      name: mysql
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: example-password
```

Then run the following to expose the port:
```shell
kubectl expose pod some-mysql --name some-mysql-3306 \
  --type LoadBalancer --port 3306 --protocol TCP
```

Or, use the following content for the `docker-compose.yml` file, then run `docker-compose up`.
```yaml
version: '2'
services:
  mysql:
    image: launcher.gcr.io/google/mysql5
    environment:
      MYSQL_ROOT_PASSWORD: example-password
```

Or, run `docker` from your shell:
```shell
docker run \
  --name some-mysql \
  -e MYSQL_ROOT_PASSWORD=example-password \
  -d \
  launcher.gcr.io/google/mysql5
```

MySQL server is accessible on port 3306.

For information about how to retain your database across restarts, see [Use a persistent data volume](#use-a-persistent-data-volume).

See [Configurations](#configurations) for how to customize your MySQL service instance.

Also see [Securely set up the server](#securely-set-up-the-server) for how to bootstrap the server with a more secure root password, without exposing it on the command line.

## Use a persistent data volume

We can store MySQL data on a persistent volume. This way the database remains intact across restarts.

To deploy to your Kubernetes cluster, copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-mysql
  labels:
    name: some-mysql
spec:
  containers:
    - image: launcher.gcr.io/google/mysql5
      name: mysql
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: example-password
      volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
          subPath: data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data
---
# Request a persistent volume from the cluster using a Persistent Volume Claim.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: data
  annotations:
    volume.alpha.kubernetes.io/storage-class: default
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 5Gi
```

Then run the following to expose the port:
```shell
kubectl expose pod some-mysql --name some-mysql-3306 \
  --type LoadBalancer --port 3306 --protocol TCP
```

Or, use the following content for the `docker-compose.yml` file, then run `docker-compose up`.
```yaml
version: '2'
services:
  mysql:
    image: launcher.gcr.io/google/mysql5
    environment:
      MYSQL_ROOT_PASSWORD: example-password
    volumes:
      - /my/persistent/dir/mysql:/var/lib/mysql
```

Or, run `docker` from your shell:
```shell
docker run \
  --name some-mysql \
  -e MYSQL_ROOT_PASSWORD=example-password \
  -v /my/persistent/dir/mysql:/var/lib/mysql \
  -d \
  launcher.gcr.io/google/mysql5
```

For `docker` and `docker-compose`, `/my/persistent/dir/mysql` is the persistent directory on the host.

Note that once the database directory is established, `MYSQL_ROOT_PASSWORD` will be ignored when the instance restarts.

## Securely set up the server

A recommended way to start up your MySQL server is to have the root password generated as a onetime password. You will then log on and change this password. MySQL will not fully function until this onetime password is changed.

Start the container with both environment variables `MYSQL_RANDOM_ROOT_PASSWORD` and `MYSQL_ONETIME_PASSWORD` set to `yes`.

To deploy to your Kubernetes cluster, copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-mysql
  labels:
    name: some-mysql
spec:
  containers:
    - image: launcher.gcr.io/google/mysql5
      name: mysql
      env:
        - name: MYSQL_ONETIME_PASSWORD
          value: yes
        - name: MYSQL_RANDOM_ROOT_PASSWORD
          value: yes
```

Then run the following to expose the port:
```shell
kubectl expose pod some-mysql --name some-mysql-3306 \
  --type LoadBalancer --port 3306 --protocol TCP
```

Or, use the following content for the `docker-compose.yml` file, then run `docker-compose up`.
```yaml
version: '2'
services:
  mysql:
    image: launcher.gcr.io/google/mysql5
    environment:
      MYSQL_ONETIME_PASSWORD: yes
      MYSQL_RANDOM_ROOT_PASSWORD: yes
```

Or, run `docker` from your shell:
```shell
docker run \
  --name some-mysql \
  -e MYSQL_ONETIME_PASSWORD=yes \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -d \
  launcher.gcr.io/google/mysql5
```

You can then obtain the generated password by viewing the container log and look for the "GENERATED ROOT PASSWORD" line.

Open a shell to the container.

Run `kubectl` from your shell to connect to your Kubernetes cluster.
```shell
kubectl exec -it some-mysql -- bash
```

Or, run `docker` from your shell:
```shell
docker exec -it some-mysql bash
```

Now log in with the generated onetime password.
```
mysql -u root -p
```

Once logged in, you can change the root password.
```
ALTER USER root IDENTIFIED BY 'new-password';
```

Also see [Environment variable reference](#environment-variables) for more information.

# Command line MySQL client

This section describes how to use this image as a MySQL client.

## Connect to a running MySQL container

You can run a MySQL client directly within the container.

Run `kubectl` from your shell to connect to your Kubernetes cluster.
```shell
kubectl exec -it some-mysql -- mysql -uroot -p
```

Or, run `docker` from your shell:
```shell
docker exec -it some-mysql mysql -uroot -p
```

## Connect command line client to a remote MySQL instance

Assume that we have a MySQL instance running at `some.mysql.host` and we want to log on as `some-mysql-user` when connecting.

Run `kubectl` from your shell to connect to your Kubernetes cluster.
```shell
kubectl run \
  some-mysql-client \
  --image launcher.gcr.io/google/mysql5 \
  --rm --attach --restart=Never \
  -i \
  -- sh -c 'exec mysql -hsome.mysql.host -usome-mysql-user -p'
```

Or, run `docker` from your shell:
```shell
docker run \
  --name some-mysql-client \
  --rm \
  -it \
  launcher.gcr.io/google/mysql5 \
  sh -c 'exec mysql -hsome.mysql.host -usome-mysql-user -p'
```

# Configurations

There are several ways to configure your MySQL service instance.

## Using configuration volume

If `/my/custom/path/config-file.cnf` is the path and name of your custom configuration file, you can start your MySQL container like this.

To deploy to your Kubernetes cluster, first create the following `configmap`:
```shell
kubectl create configmap config \
  --from-file=/my/custom/path/config-file.cnf
```

Then copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-mysql
  labels:
    name: some-mysql
spec:
  containers:
    - image: launcher.gcr.io/google/mysql5
      name: mysql
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: example-password
      volumeMounts:
        - name: config
          mountPath: /etc/mysql/conf.d/config-file.cnf
  volumes:
    - name: config
      configMap:
        name: config
```

Then run the following to expose the port:
```shell
kubectl expose pod some-mysql --name some-mysql-3306 \
  --type LoadBalancer --port 3306 --protocol TCP
```

Or, use the following content for the `docker-compose.yml` file, then run `docker-compose up`.
```yaml
version: '2'
services:
  mysql:
    image: launcher.gcr.io/google/mysql5
    environment:
      MYSQL_ROOT_PASSWORD: example-password
    volumes:
      - /my/custom/path/config-file.cnf:/etc/mysql/conf.d/config-file.cnf
```

Or, run `docker` from your shell:
```shell
docker run \
  --name some-mysql \
  -e MYSQL_ROOT_PASSWORD=example-password \
  -v /my/custom/path/config-file.cnf:/etc/mysql/conf.d/config-file.cnf \
  -d \
  launcher.gcr.io/google/mysql5
```

See [Volume reference](#volumes) for more details.

## Using flags

You can specify option flags directly to `mysqld` when starting your instance. The following example sets the default encoding and collation for all tables to UTF-8.

To deploy to your Kubernetes cluster, copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-mysql
  labels:
    name: some-mysql
spec:
  containers:
    - image: launcher.gcr.io/google/mysql5
      name: mysql
      args:
        - --character-set-server=utf8mb4
        - --collation-server=utf8mb4_unicode_ci
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: example-password
```

Then run the following to expose the port:
```shell
kubectl expose pod some-mysql --name some-mysql-3306 \
  --type LoadBalancer --port 3306 --protocol TCP
```

Or, use the following content for the `docker-compose.yml` file, then run `docker-compose up`.
```yaml
version: '2'
services:
  mysql:
    image: launcher.gcr.io/google/mysql5 \
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_unicode_ci
    environment:
      MYSQL_ROOT_PASSWORD: example-password
```

Or, run `docker` from your shell:
```shell
docker run \
  --name some-mysql \
  -e MYSQL_ROOT_PASSWORD=example-password \
  -d \
  launcher.gcr.io/google/mysql5 \
  --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

You can also list all available options (several pages long).

Run `kubectl` from your shell to connect to your Kubernetes cluster.
```shell
kubectl run \
  some-mysql-client \
  --image launcher.gcr.io/google/mysql5 \
  --rm --attach --restart=Never \
  -- --verbose --help
```

Or, run `docker` from your shell:
```shell
docker run \
  --name some-mysql-client \
  --rm \
  launcher.gcr.io/google/mysql5 \
  --verbose --help
```

# Maintenance

## Creating database dumps

All databases can be dumped into a `/some/path/all-databases.sql` file on the host using the following command.

Run `kubectl` from your shell to connect to your Kubernetes cluster.
```shell
kubectl exec -it some-mysql -- sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/all-databases.sql
```

Or, run `docker` from your shell:
```shell
docker exec -it some-mysql sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/all-databases.sql
```

# References

## Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 3306 | Standard MySQL port. |

## Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
| MYSQL_ROOT_PASSWORD | The password for `root` superuser. Required. <br><br> Instead of the explicit password string, a file path can also be used, in which case the content of the file is the password. |
| MYSQL_DATABASE | Optionally specifies the name of the database to be created at startup. |
| MYSQL_USER | Optionally specifies a new user to be created at startup. Must be used in conjunction with `MYSQL_PASSWORD`. Note that this user is in addition to the default `root` superuser. <br><br> If `MYSQL_DATABASE` is also specified, this user will be granted superuser permissions (i.e. `GRANT_ALL`) for that database. |
| MYSQL_PASSWORD | Used in conjunction with `MYSQL_USER` to specify the password. |
| MYSQL_RANDOM_ROOT_PASSWORD | If set to `yes`, a random initial password for `root` superuser will be generated. This password will be printed to stdout as `GENERATED ROOT PASSWORD: ...` |
| MYSQL_ONETIME_PASSWORD | If set to `yes`, the initial password for `root` superuser, be it specified via `MYSQL_ROOT_PASSWORD` or randomly generated (see `MYSQL_RANDOM_ROOT_PASSWORD`), must be changed after startup. |

## Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
| /var/lib/mysql | Stores the database files. |
| /etc/mysql/conf.d | Contains custom `.cnf` configuration files. <br><br> MySQL startup configuration is specified in `/etc/mysql/my.cnf`, which in turn includes any `.cnf` files found in `/etc/mysql/conf.d` directory. |
