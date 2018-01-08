# Running AllegroGraph in kubernetes

This container and condfiguration will run a single node AllegroGraph server in
[Kubernetes](https://kubernetes.io).

## Docker Image

The `DockerFile` describes a basic image and is publicly available as `alexmilowski/allegrograph-kubernetes:latest`. It is very
similar to the standard AllegroGraph docker image but with two general differences:

 1. You can change various aspects of the initial configuration during the build (e.g., the server admin password).
 2. You can mount an empty initial data directory and it will bootstrap the configuration files. This allows you to use a
    persistent volume claim for the data directory of the datbase.

## Kubernetes configuration

The basic Kubernetes setup is contained in two files:

 * `agraph-volume-claim.yaml` - a volume claim for the database storage
 * `agraph.yaml` - the AllegroGraph Deployment

## Deploying a Single Node Server on kubernetes

The following procedure can be used to deploy a single node AllegroGraph instance:

 1. You must first create a persistent volume to store your data. There are many ways this can be done and it depends on
    how you choose to run your Kubernetes cluster. For example, a simple volume via NFS might be (in `volume.yaml`):
    ```
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: agraph-volume-1-nfs
      labels:
        storage-backend: nfs
        content: agraph-volume-1
    spec:
      capacity:
        storage: 1024Gi
      accessModes:
        - ReadWriteMany
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: ...
        path: "..."
        readOnly: false
    ```

    and then:

    ```
    kubectl -n agraph create -f volume.yaml
    ```
 2. Then you must claim the volume named `agraph-storage-1` via `agraph-volume-claim.yaml`. If you changed the name in `content`
    when defining the volume, you'll have to edit this file first. Otherwise, do the following:

    ```
    kubectl -n agraph create -f agraph-volume-claim.yaml
    ```

 3. Finally, deploy Allegrograph via `agraph.yaml` using the claimed volume `agraph-storage-1` as the `/data` directory:

    ```
    kubectl -n agraph create -f agraph.yamnl
    ```

## Checking your Deployment

Once you have deployed AllegroGraph you can either setup an ingress to the standard port or you can forward the port to your local machine. A simple way to test is to forward the port via the following:

```
kubectl -n agraph port-forward `kubectl -n agraph get pods --no-headers | awk '{ print $1 }' | grep agraph-deployment` 10035 10035
```

The inner kubectl command returns the deployment name:

```
kubectl -n agraph get pods --no-headers | awk '{ print $1 }' | grep agraph-deployment
```

The outer kubectl command fowards the port 10035 to your local machine.

You should now be able to access your deployment of AllegroGraph at [http://localhost:10035](http://localhost:10035) with the password specified used when you build the Docker image (see `Dockerfile` for the default).

## Creating a Service

The file `agraph-service.yaml` contains an example of a service deployment. There are a number of changes you may want to make:

 * if you just want an internal service only available within the cluster, either delete 'type: LoadBalancer' or change it to ClusterIP.
 * if you want an external IP, you should enter an external IP of one of your Kubernetes nodes in the `externalIPs` array.

   You can use the this to find the IP addresses of your nodes:
   ```
   kubectl describe nodes | grep IP
   ```
   and then pick one or more to expose the service. The `port` value will then be available on that IP/Node when you create the service.

After editing the service definition, the service can be created by:

```
kubectl create -f agraph-service.yaml
```
