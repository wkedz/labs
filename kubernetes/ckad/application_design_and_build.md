---
id: 2024-09-17-08:20-kubernetes-ckad
aliases: []
tags:
  - k8s
  - ckad
date: "2024-09-17"
title: kubernetes-ckad
---

# kubernetes-ckad

**Create a multi-container pod with a main application container running and a sidecar container running a logging agent. The logging agent should read logs from a shared volume and output them to the console. Verify that the logging agent is correctly processing the logs from the container.**

```yaml
# app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      initContainers:
      - image: alpine:latest
        name: init 
        command: ['sh','-c', 'touch /opt/logs.txt']
        restartPolicy: Never
        volumeMounts:
        - name: logs
          mountPath: /opt
      containers:
      - image: alpine:latest
        name: myapp
        command: ['sh','-c', 'while true; do echo "$(date) logging" >> /opt/logs.txt; sleep 1; done']
        volumeMounts:
        - name: logs
          mountPath: /opt
      - image: alpine:latest
        name: logshipper
        command: ['sh', '-c', 'tail -F /opt/logs.txt']
        volumeMounts:
        - name: logs
          mountPath: /opt
      volumes:
        - name: logs
          emptyDir: {}
```
```bash
$ kubectl apply -f app.yaml
$ kubectl get deployments myapp
$ kubectl get pods -l app=myapp
$ kubeclt logs POD-NAME -c logshipper
$ kubectl delete -f app.yaml
```

**Create a Kubernetes Deployment named data-processor with an init container that downloads a file from a specified URL before the main application starts. Use a shared volume to pass the downloaded file to the main container. Verify that the main container can access the file.**

```yaml
#data-procesor-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: data-processor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: data-processor
  template:
    metadata:
      labels:
        app: data-processor
    spec:
      volumes:
      - name: shared-data
        emptyDir: {}
      initContainers:
      - name: init-downloader
        image: busybox
        command: ["sh", "-c"]
        args:
          - wget -O /shared/file.txt <URL>; # Replace <URL> with the actual URL
        volumeMounts:
        - name: shared-data
          mountPath: /shared
      containers:
      - name: main-app
        image: busybox
        command: ["sh", "-c"]
        args: ["cat /app/file.txt; sleep 3600"]
        volumeMounts:
        - name: shared-data
          mountPath: /app
```

```bash
kubectl apply -f data-processor-deployment.yaml
kubectl exec -it $(kubectl get pod -l app=data-processor -o jsonpath="{.items[0].metadata.name}") -- cat /app/file.txt
```

Resources:

- [Kubernetes Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Kubernetes Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)



**Deploy a pod that uses a PersistentVolumeClaim (PVC) to store data persistently. Modify the pod to also use an ephemeral volume for temporary storage. Confirm that the persistent data is retained after pod restarts, but ephemeral data is lost.**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-test-pod
spec:
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: pvc-data
    - name: ephemeral-storage
      emptyDir: {}
  containers:
    - name: app-container
      image: busybox
      command: ["sh", "-c"]
      args: ["sleep 3600"]
      volumeMounts:
        - name: persistent-storage
          mountPath: /mnt/persistent
        - name: ephemeral-storage
          mountPath: /mnt/ephemeral
```
```bash
kubectl apply -f pv-pvc.yaml
kubectl apply -f storage-test-pod.yaml
kubectl exec -it storage-test-pod -- sh -c "echo 'persistent data' > /mnt/persistent/data.txt"
kubectl exec -it storage-test-pod -- sh -c "echo 'ephemeral data' > /mnt/ephemeral/data.txt"
kubectl exec -it storage-test-pod -- cat /mnt/persistent/data.txt
kubectl exec -it storage-test-pod -- cat /mnt/ephemeral/data.txt
kubectl delete pod storage-test-pod
kubectl apply -f storage-test-pod.yaml
kubectl exec -it storage-test-pod -- cat /mnt/persistent/data.txt
kubectl exec -it storage-test-pod -- cat /mnt/ephemeral/data.txt
```

Resources:

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)
- [EmptyDir Volumes](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)

**Create a Dockerfile to build a Go-based microservice application. Deploy the image to your Kubernetes cluster and validate its functionality by sending sample requests.**

### Dockerfile for a Go-based Microservice

```Dockerfile
# Use an official Go image as a build environment
FROM golang:1.20-alpine as builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app
RUN go build -o main .

# Use a minimal base image
FROM alpine:latest

# Set the Current Working Directory inside the container
WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./main"]
```

### Kubernetes YAML to Deploy the Microservice

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-microservice
spec:
  replicas: 1
  selector:
    matchLabels:
      app: go-microservice
  template:
    metadata:
      labels:
        app: go-microservice
    spec:
      containers:
      - name: go-container
        image: <your-dockerhub-username>/go-microservice:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: go-microservice-service
spec:
  type: NodePort
  selector:
    app: go-microservice
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: 30007
```

1. **Build and push the Docker image:**
   ```bash
   docker build -t <your-dockerhub-username>/go-microservice:latest .
   docker push <your-dockerhub-username>/go-microservice:latest
   ```

2. **Deploy the application to Kubernetes:**
   ```bash
   kubectl apply -f go-microservice-deployment.yaml
   ```

3. **Validate the deployment by sending a request:**
   ```bash
   curl http://<node-ip>:30007/
   ```

   Replace `<node-ip>` with the IP address of your Kubernetes node.

### Official Kubernetes Resources

- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Dockerizing a Go Application](https://docs.docker.com/samples/golang/)


**Design a pod with three containers: one main application container, one sidecar for logging, and one for metrics collection. Use shared volumes for inter-container communication.**

### YAML for a Pod with Three Containers
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: main-app
    image: nginx:latest
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
    - name: shared-metrics
      mountPath: /var/metrics

  - name: log-sidecar
    image: busybox
    command: ["sh", "-c"]
    args: ["tail -f /var/log/nginx/access.log"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx

  - name: metrics-sidecar
    image: busybox
    command: ["sh", "-c"]
    args: ["while true; do echo 'metrics data' > /var/metrics/metrics.txt; sleep 30; done"]
    volumeMounts:
    - name: shared-metrics
      mountPath: /var/metrics

  volumes:
  - name: shared-logs
    emptyDir: {}
  - name: shared-metrics
    emptyDir: {}
```

### `kubectl` Commands

1. **Create the Pod:**
   ```bash
   kubectl apply -f multi-container-pod.yaml
   ```

2. **Verify logs generated by the main application are accessible by the log sidecar:**
   ```bash
   kubectl exec -it multi-container-pod -c log-sidecar -- tail /var/log/nginx/access.log
   ```

3. **Verify metrics collected by the metrics sidecar:**
   ```bash
   kubectl exec -it multi-container-pod -c metrics-sidecar -- cat /var/metrics/metrics.txt
   ```

### Official Kubernetes Resources

- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Multi-Container Pods](https://kubernetes.io/docs/concepts/workloads/pods/#using-pods)
- [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)

**Modify an existing container image to update its base image due to a security vulnerability. Redeploy the updated image and confirm that the vulnerability is mitigated.**


### Steps to Modify the Container Image

1. **Pull the existing image:**
   ```bash
   docker pull <your-image>:<tag>
   ```

2. **Create a new Dockerfile with the updated base image:**

   ```Dockerfile
   # Use an updated base image to address the security vulnerability
   FROM <updated-base-image>:<version>
   
   # Copy the application files from the old image
   COPY --from=<your-image>:<tag> /app /app
   
   # Set the working directory
   WORKDIR /app
   
   # Install any necessary dependencies (if needed)
   RUN apt-get update && apt-get install -y <dependencies>
   
   # Command to run the application
   CMD ["./start-app.sh"]
   ```

3. **Build the updated image:**
   ```bash
   docker build -t <your-dockerhub-username>/updated-image:latest .
   ```

4. **Push the updated image to your registry:**
   ```bash
   docker push <your-dockerhub-username>/updated-image:latest
   ```

### Kubernetes YAML to Redeploy the Updated Image

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: updated-app-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: updated-app
  template:
    metadata:
      labels:
        app: updated-app
    spec:
      containers:
      - name: updated-app-container
        image: <your-dockerhub-username>/updated-image:latest
        ports:
        - containerPort: 80
```

### `kubectl` Commands

1. **Apply the updated Deployment:**
   ```bash
   kubectl apply -f updated-app-deployment.yaml
   ```

2. **Verify the updated pods are running:**
   ```bash
   kubectl get pods -l app=updated-app
   ```

3. **Check the logs or connect to the container to confirm the application is functioning correctly:**
   ```bash
   kubectl logs -l app=updated-app
   ```

### Official Kubernetes Resources

- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Rolling Updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)


**Create a Deployment that automatically scales up when CPU usage exceeds 70%. Test the autoscaling behavior by simulating high CPU load.**

### YAML for the Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-autoscale-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu-autoscale
  template:
    metadata:
      labels:
        app: cpu-autoscale
    spec:
      containers:
      - name: cpu-intensive-app
        image: vish/stress
        resources:
          requests:
            cpu: "100m"
          limits:
            cpu: "200m"
        args:
          - "-cpus"
          - "1"
```

### YAML for the Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: cpu-autoscale-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cpu-autoscale-deployment
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
```

### `kubectl` Commands

1. **Create the Deployment:**
   ```bash
   kubectl apply -f cpu-autoscale-deployment.yaml
   ```

2. **Create the Horizontal Pod Autoscaler:**
   ```bash
   kubectl apply -f cpu-autoscale-hpa.yaml
   ```

3. **Simulate High CPU Load:**
   You can simulate high CPU usage by increasing the CPU load in the existing container or by adjusting the `-cpus` argument to simulate more CPU consumption:
   ```bash
   kubectl exec -it $(kubectl get pod -l app=cpu-autoscale -o jsonpath="{.items[0].metadata.name}") -- sh -c "stress --cpu 1 --timeout 600"
   ```

4. **Check the status of the HPA:**
   ```bash
   kubectl get hpa cpu-autoscale-hpa
   ```

5. **Verify the scaling behavior:**
   Watch the number of pods increase:
   ```bash
   kubectl get pods -l app=cpu-autoscale --watch
   ```

### Official Kubernetes Resources

- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Resource Management for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

**Deploy an application that requires persistent storage using NFS. Set up the PersistentVolume and PersistentVolumeClaim and mount it to the pod.**

### YAML for the PersistentVolume (PV)
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  nfs:
    path: /path/to/nfs/share # Replace with your NFS server path
    server: <nfs-server-ip>   # Replace with your NFS server IP
```

### YAML for the PersistentVolumeClaim (PVC)
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```

### YAML for the Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nfs-storage-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: nfs-storage
      mountPath: /mnt/nfs
  volumes:
  - name: nfs-storage
    persistentVolumeClaim:
      claimName: nfs-pvc
```

### `kubectl` Commands

1. **Create the PersistentVolume:**
   ```bash
   kubectl apply -f nfs-pv.yaml
   ```

2. **Create the PersistentVolumeClaim:**
   ```bash
   kubectl apply -f nfs-pvc.yaml
   ```

3. **Deploy the Pod:**
   ```bash
   kubectl apply -f nfs-storage-pod.yaml
   ```

4. **Verify the Pod is running and check the mounted NFS volume:**
   ```bash
   kubectl exec -it nfs-storage-pod -- sh -c "touch /mnt/nfs/testfile && ls /mnt/nfs"
   ```

   This command will create a file on the NFS mount to ensure it's working correctly.

### Official Kubernetes Resources

- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)
- [Using NFS for Persistent Storage](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)


**Create a pod with an ephemeral volume using an emptyDir volume type and demonstrate its lifecycle.**

### YAML for the Pod with an emptyDir Volume
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ephemeral-volume-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ["sh", "-c"]
    args:
      - |
        echo "Writing to emptyDir volume..." > /mnt/emptydir/testfile.txt;
        echo "Sleeping for 3600 seconds...";
        sleep 3600;
    volumeMounts:
    - name: ephemeral-storage
      mountPath: /mnt/emptydir
  volumes:
  - name: ephemeral-storage
    emptyDir: {}
```

### `kubectl` Commands

1. **Create the Pod:**
   ```bash
   kubectl apply -f ephemeral-volume-pod.yaml
   ```

2. **Verify the file was written to the emptyDir volume:**
   ```bash
   kubectl exec -it ephemeral-volume-pod -- cat /mnt/emptydir/testfile.txt
   ```

3. **Delete the Pod:**
   ```bash
   kubectl delete pod ephemeral-volume-pod
   ```

4. **Recreate the Pod and check the emptyDir volume:**
   ```bash
   kubectl apply -f ephemeral-volume-pod.yaml
   kubectl exec -it ephemeral-volume-pod -- ls /mnt/emptydir
   ```

   This command should show that the `testfile.txt` is no longer present, demonstrating the ephemeral nature of the `emptyDir` volume.

### Official Kubernetes Resources

- [emptyDir Volumes](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)
- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)


**Write a Kubernetes manifest to deploy an application with init containers that perform database migrations before starting the main application container.**

### YAML for the Deployment with Init Containers
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-db-migrations
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: main-app
        image: myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          value: "postgresql://user:password@db-host:5432/mydatabase"
        - name: DB_MIGRATION_STATUS
          value: "completed"
      initContainers:
      - name: db-migrate
        image: myapp-db-migrate:latest
        env:
        - name: DATABASE_URL
          value: "postgresql://user:password@db-host:5432/mydatabase"
        command:
        - "sh"
        - "-c"
        - |
          echo "Running database migrations...";
          ./migrate -database ${DATABASE_URL} -path /migrations up;
          echo "Database migrations completed."
```

### `kubectl` Commands

1. **Create the Deployment:**
   ```bash
   kubectl apply -f app-with-db-migrations.yaml
   ```

2. **Check the status of the init container to ensure the migration ran successfully:**
   ```bash
   kubectl get pods -l app=myapp
   kubectl logs <pod-name> -c db-migrate
   ```

3. **Verify the main application is running after the migrations:**
   ```bash
   kubectl logs <pod-name> -c main-app
   ```

   Replace `<pod-name>` with the actual name of the pod running your application.

### Official Kubernetes Resources

- [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

**Design a multi-container pod that runs a cache server (e.g., Redis) and a web server. Set up a shared volume between the two containers for data exchange.**
### YAML for the Multi-Container Pod with a Shared Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-cache-pod
spec:
  containers:
  - name: redis-server
    image: redis:latest
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: web-server
    image: nginx:latest
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  volumes:
  - name: shared-data
    emptyDir: {}
```

### `kubectl` Commands

1. **Create the Pod:**
   ```bash
   kubectl apply -f web-cache-pod.yaml
   ```

2. **Verify both containers are running:**
   ```bash
   kubectl get pods web-cache-pod
   ```

3. **Check the contents of the shared volume in the web server:**
   ```bash
   kubectl exec -it web-cache-pod -c web-server -- ls /usr/share/nginx/html
   ```

4. **Check the contents of the shared volume in the Redis server:**
   ```bash
   kubectl exec -it web-cache-pod -c redis-server -- ls /data
   ```

### Official Kubernetes Resources

- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)
- [Multi-Container Pods](https://kubernetes.io/docs/concepts/workloads/pods/#using-pods)



**Configure a Deployment with a specific container image pulled from a private registry. Set up the necessary Kubernetes Secret to handle authentication.**

### Step 1: Create a Kubernetes Secret for Docker Registry Authentication

You need to create a Kubernetes Secret to store the Docker registry credentials. The following command creates a Secret named `regcred` in the `default` namespace:

```bash
kubectl create secret docker-registry regcred \
    --docker-server=<your-docker-registry-url> \
    --docker-username=<your-username> \
    --docker-password=<your-password> \
    --docker-email=<your-email>
```

Replace the placeholders with your actual Docker registry information:
- `<your-docker-registry-url>`: The URL of your private Docker registry.
- `<your-username>`: Your Docker registry username.
- `<your-password>`: Your Docker registry password.
- `<your-email>`: Your Docker registry email.

### Step 2: YAML for the Deployment

Now, create a Deployment that uses the Secret to pull the container image from the private registry:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-registry-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp-container
        image: <your-docker-registry-url>/myapp:latest
        ports:
        - containerPort: 8080
      imagePullSecrets:
      - name: regcred
```

Replace `<your-docker-registry-url>/myapp:latest` with the actual image path and tag from your private registry.

### Step 3: Apply the Deployment

1. **Apply the Secret:**
   If the Secret hasn't been created yet, use the command provided in Step 1.

2. **Deploy the Application:**
   ```bash
   kubectl apply -f private-registry-deployment.yaml
   ```

3. **Verify the Pod is Running:**
   ```bash
   kubectl get pods -l app=myapp
   ```

### Official Kubernetes Resources

- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [ImagePullSecrets](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

