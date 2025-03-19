---
id: 2024-09-17-08:24-services_and_networkind
aliases: []
tags:
  - k8s
  - ckad
date: "2024-09-17"
title: services_and_networkind
---

# services_and_networkind

**Implement a NetworkPolicy that allows ingress traffic to a pod only from pods with a specific label within the same namespace. Test the policy to ensure unauthorized traffic is blocked.**

### Step 1: Set Up the Pods

First, let's assume you have two pods in the same namespace:

- `app-pod`: The pod that you want to protect with a NetworkPolicy.
- `allowed-pod`: The pod that should be allowed to communicate with `app-pod`.

You might also have a third pod, `blocked-pod`, which should not be able to communicate with `app-pod`.

#### 1.1 Deploy the `app-pod` and `allowed-pod`

Create a file named `app-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  labels:
    app: my-app
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
```

Create a file named `allowed-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: allowed-pod
  labels:
    access: granted
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

Create a file named `blocked-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: blocked-pod
  labels:
    access: denied
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

Deploy the pods:

```bash
kubectl apply -f app-pod.yaml
kubectl apply -f allowed-pod.yaml
kubectl apply -f blocked-pod.yaml
```

### Step 2: Implement the NetworkPolicy

Now, create a NetworkPolicy that only allows ingress traffic to `app-pod` from pods with the label `access: granted`.

Create a file named `network-policy.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-specific-ingress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: granted
```

This NetworkPolicy does the following:

- **`podSelector`**: Targets the pod(s) with the label `app: my-app`, which in this case is `app-pod`.
- **`policyTypes`**: Specifies that this policy is for ingress traffic.
- **`ingress`**: Allows traffic only from pods with the label `access: granted`.

Apply the NetworkPolicy:

```bash
kubectl apply -f network-policy.yaml
```

### Step 3: Test the NetworkPolicy

#### 3.1 Verify Allowed Traffic

To test that `allowed-pod` can communicate with `app-pod`, exec into `allowed-pod` and attempt to access `app-pod`:

```bash
kubectl exec -it allowed-pod -- wget -qO- http://app-pod
```

If the NetworkPolicy is configured correctly, this command should succeed, and you should see the Nginx welcome page content.

#### 3.2 Verify Blocked Traffic

Next, test that `blocked-pod` cannot communicate with `app-pod`:

```bash
kubectl exec -it blocked-pod -- wget -qO- http://app-pod
```

This command should fail or hang, as the NetworkPolicy blocks traffic from `blocked-pod` to `app-pod`.

### Step 4: Clean Up

After testing, you can clean up the resources:

```bash
kubectl delete pod app-pod allowed-pod blocked-pod
kubectl delete networkpolicy allow-specific-ingress
```

### Step 5: Additional Considerations

- **Namespace Isolation**: The above NetworkPolicy only applies within the same namespace. If you want to allow traffic from other namespaces, you'll need to modify the `from` clause to include the `namespaceSelector`.
- **Default Deny Policy**: If you have other ingress policies, be sure to review them as well. If you want to deny all other traffic by default, consider adding a default deny policy.

### Official Kubernetes Resources

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)


**Expose a Deployment named my-app using a ClusterIP service and then modify it to use a NodePort service. Verify external access to the application and troubleshoot any connectivity issues.**

### Step 1: Expose the Deployment Using a ClusterIP Service

To start, we'll expose the `my-app` deployment using a ClusterIP service, which is the default service type in Kubernetes.

#### 1.1 Create the ClusterIP Service

You can create the ClusterIP service using the following YAML. Save this as `my-app-clusterip-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  namespace: default
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
```

This service configuration does the following:

- **`selector`**: Selects the pods labeled with `app: my-app`.
- **`ports`**: Maps port 80 on the service to port 8080 on the pod.
- **`type: ClusterIP`**: Exposes the service only within the cluster (no external access).

Apply the service configuration:

```bash
kubectl apply -f my-app-clusterip-service.yaml
```

#### 1.2 Verify the ClusterIP Service

To check that the service is correctly set up:

1. **Get the Service Details:**

   ```bash
   kubectl get svc my-app-service
   ```

   You should see an output similar to this:

   ```
   NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
   my-app-service   ClusterIP   10.96.178.123   <none>        80/TCP    10s
   ```

2. **Test the Service Within the Cluster:**

   You can test the service by creating a temporary pod and curling the service:

   ```bash
   kubectl run curl-pod --image=busybox --restart=Never --rm -it -- curl my-app-service
   ```

   If the service is working, you should receive a response from your `my-app` application.

### Step 2: Modify the Service to Use NodePort

Now, let's modify the service to change its type from `ClusterIP` to `NodePort`, which will expose the service on a port of each node in the cluster, allowing external access.

#### 2.1 Modify the Service Type to NodePort

You can either edit the service manually or apply a new YAML file. Below is the updated YAML configuration. Save this as `my-app-nodeport-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  namespace: default
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
    nodePort: 30080  # Optional: Specify a custom NodePort, otherwise one will be assigned
  type: NodePort
```

Apply the updated service configuration:

```bash
kubectl apply -f my-app-nodeport-service.yaml
```

#### 2.2 Verify the NodePort Service

1. **Get the Service Details:**

   ```bash
   kubectl get svc my-app-service
   ```

   You should see an output similar to this:

   ```
   NAME             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
   my-app-service   NodePort   10.96.178.123   <none>        80:30080/TCP   10m
   ```

   Here, `30080` is the NodePort assigned to the service.

2. **Access the Application Externally:**

   Now, you can access the application externally using any node's IP address and the NodePort:

   ```bash
   curl http://<node-ip>:30080
   ```

   Replace `<node-ip>` with the IP address of any node in your cluster.

### Step 3: Troubleshoot Connectivity Issues

If you experience any issues while accessing the application externally, here are some common troubleshooting steps:

1. **Ensure the Nodes' Security Groups or Firewalls Allow the NodePort:**

   If you're running your cluster on a cloud provider, make sure that the security groups or firewall rules allow traffic to the NodePort range (usually `30000-32767` by default).

2. **Verify the Pod is Running:**

   Check that the `my-app` pods are running correctly:

   ```bash
   kubectl get pods -l app=my-app
   ```

   If the pods are not running, describe them to get more details:

   ```bash
   kubectl describe pod <pod-name>
   ```

3. **Check Service Endpoints:**

   Ensure the service endpoints are correctly mapped to the pods:

   ```bash
   kubectl get endpoints my-app-service
   ```

   This should list the IP addresses and ports of the pods backing the service.

4. **Inspect Node Logs:**

   If you're still having trouble, inspect the logs of the nodes or the application for any errors:

   ```bash
   kubectl logs <pod-name>
   ```

5. **Test Node Connectivity:**

   If the nodes are not accessible, verify network connectivity between your local machine and the Kubernetes nodes. Ensure that the nodes' public IP addresses are correct and reachable.

### Step 4: Clean Up

Once you've finished testing, you can clean up the resources:

```bash
kubectl delete svc my-app-service
kubectl delete deployment my-app
```

### Official Kubernetes Resources

- [Services in Kubernetes](https://kubernetes.io/docs/concepts/services-networking/service/)
- [kubectl port-forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)


**Create an Ingress resource to expose multiple services (e.g., app1 and app2) using different paths under the same domain. Validate that requests to /app1 and /app2 route to the correct backend services.**

To create an Ingress resource that exposes multiple services (e.g., `app1` and `app2`) using different paths under the same domain, follow these steps:

### Step 1: Deploy the Application Services

First, we need to deploy two sample applications (`app1` and `app2`) in your Kubernetes cluster. Each application will be exposed using different paths.

#### 1.1 Deploy `app1`

Create a deployment and service for `app1`. Save the following YAML as `app1-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: hashicorp/http-echo
        args:
          - "-text=Hello from App1"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  selector:
    app: app1
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Apply the deployment and service:

```bash
kubectl apply -f app1-deployment.yaml
```

#### 1.2 Deploy `app2`

Similarly, create a deployment and service for `app2`. Save the following YAML as `app2-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: hashicorp/http-echo
        args:
          - "-text=Hello from App2"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: app2-service
spec:
  selector:
    app: app2
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Apply the deployment and service:

```bash
kubectl apply -f app2-deployment.yaml
```

### Step 2: Create the Ingress Resource

Now that the services are running, we can create an Ingress resource to route traffic to these services based on the request path.

#### 2.1 Create the Ingress Resource

Save the following YAML as `ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: yourdomain.com  # Replace with your actual domain or use a placeholder for testing
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

This Ingress resource does the following:

- **`host`**: Specifies the domain (`yourdomain.com`) under which the paths `/app1` and `/app2` will be routed.
- **`paths`**: Defines the paths `/app1` and `/app2` and maps them to the respective services (`app1-service` and `app2-service`).
- **`nginx.ingress.kubernetes.io/rewrite-target: /`**: Ensures that the requests are correctly routed to the services without retaining the path prefix.

Apply the Ingress resource:

```bash
kubectl apply -f ingress.yaml
```

### Step 3: Validate the Ingress Configuration

#### 3.1 Check the Ingress Resource

Verify that the Ingress resource has been created:

```bash
kubectl get ingress
```

You should see output like this:

```
NAME           CLASS    HOSTS             ADDRESS          PORTS   AGE
app-ingress    <none>   yourdomain.com    <external-ip>    80      10s
```

#### 3.2 Test Access to the Applications

To test the routing, you can use `curl` or a web browser to access the following URLs:

- **Access `app1`**:

  ```bash
  curl http://yourdomain.com/app1
  ```

  You should see the response:

  ```
  Hello from App1
  ```

- **Access `app2`**:

  ```bash
  curl http://yourdomain.com/app2
  ```

  You should see the response:

  ```
  Hello from App2
  ```

If you don’t have a domain name, you can simulate it by editing your `/etc/hosts` file (on Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (on Windows) and adding an entry like this:

```
<external-ip-of-ingress-controller>   yourdomain.com
```

### Step 4: Troubleshoot Connectivity Issues

If you experience any issues accessing the applications:

1. **Check Ingress Controller Logs**:

   If you're using NGINX Ingress Controller, check the logs to identify any issues:

   ```bash
   kubectl logs -n <namespace-of-ingress-controller> <ingress-controller-pod>
   ```

2. **Verify DNS Settings**:

   Ensure that your domain name resolves to the correct IP address of the Ingress controller.

3. **Test Direct Service Access**:

   Bypass the Ingress by port-forwarding directly to the service to ensure the service is working:

   ```bash
   kubectl port-forward svc/app1-service 8080:80
   ```

   Then, access it via `http://localhost:8080`.

4. **Check Network Policies**:

   If you’re using NetworkPolicies, ensure they allow traffic to the services from the Ingress controller.

### Step 5: Clean Up

Once you're done testing, clean up the resources:

```bash
kubectl delete deployment app1 app2
kubectl delete service app1-service app2-service
kubectl delete ingress app-ingress
```

### Official Resources

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)


**Configure TLS for an Ingress resource using a self-signed certificate. Deploy the Ingress and validate that it correctly routes HTTPS traffic to the application backend.**

### Step 1: Generate a Self-Signed Certificate and Key

First, you need to generate a self-signed TLS certificate and key. You can do this using `openssl`.

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=yourdomain.com/O=yourdomain.com"
```

This command generates two files:

- `tls.crt`: The self-signed certificate.
- `tls.key`: The private key for the certificate.

### Step 2: Create a Kubernetes Secret to Store the TLS Certificate

Next, create a Kubernetes secret to store the TLS certificate and key. This secret will be used by the Ingress resource.

```bash
kubectl create secret tls my-tls-secret --cert=tls.crt --key=tls.key
```

Verify that the secret was created:

```bash
kubectl get secrets
```

You should see `my-tls-secret` in the list of secrets.

### Step 3: Deploy the Application Services

Ensure you have the application services (`app1` and `app2`) already deployed. If not, you can deploy them as described in the previous example.

### Step 4: Create an Ingress Resource with TLS

Now, create an Ingress resource that uses the TLS secret to serve HTTPS traffic. Save the following YAML as `tls-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - yourdomain.com
    secretName: my-tls-secret
  rules:
  - host: yourdomain.com
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

### Explanation

- **`tls`**: Specifies the domain and the secret containing the TLS certificate and key.
- **`host`**: Specifies the domain name (e.g., `yourdomain.com`) that the Ingress will respond to.
- **`paths`**: Routes traffic to `/app1` and `/app2` to the respective backend services.

Apply the Ingress configuration:

```bash
kubectl apply -f tls-ingress.yaml
```

### Step 5: Validate the Ingress with TLS

#### 5.1 Check the Ingress Resource

Verify that the Ingress resource was created:

```bash
kubectl get ingress tls-ingress
```

You should see output similar to this:

```
NAME          CLASS    HOSTS             ADDRESS          PORTS     AGE
tls-ingress   <none>   yourdomain.com    <external-ip>    80, 443   10s
```

#### 5.2 Test HTTPS Access to the Application

To test the Ingress resource with TLS:

1. **Add a Hosts File Entry (if needed):**

   If you're using a local setup and do not have a domain name, you can map `yourdomain.com` to the external IP of your Ingress controller by editing your `/etc/hosts` file (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` file (Windows):

   ```
   <external-ip>   yourdomain.com
   ```

2. **Access the Application via HTTPS:**

   Use `curl` or a web browser to access the application over HTTPS:

   - For `app1`:

     ```bash
     curl -k https://yourdomain.com/app1
     ```

     The `-k` option tells `curl` to ignore SSL certificate validation (because it's self-signed).

     You should see the response `Hello from App1`.

   - For `app2`:

     ```bash
     curl -k https://yourdomain.com/app2
     ```

     You should see the response `Hello from App2`.

#### 5.3 Troubleshoot Any Issues

If you encounter issues:

- **Check Ingress Controller Logs:**

  ```bash
  kubectl logs -n <namespace-of-ingress-controller> <ingress-controller-pod>
  ```

- **Verify the Secret:**

  Ensure the secret `my-tls-secret` is correctly configured and associated with the Ingress.

- **Check the Ingress Status:**

  Ensure the Ingress is pointing to the correct services and is correctly configured.

### Step 6: Clean Up

After testing, you can clean up the resources:

```bash
kubectl delete ingress tls-ingress
kubectl delete secret my-tls-secret
kubectl delete deployment app1 app2
kubectl delete service app1-service app2-service
```

### Official Resources

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [TLS Secrets](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)


**Create a NetworkPolicy that allows only selected pods to communicate with a specific backend service. Test the policy by trying to connect from unauthorized pods.**

### Step 1: Deploy the Backend Service

First, let's deploy the backend service that we want to protect using a NetworkPolicy. We'll create a simple backend service called `backend`.

#### 1.1 Create the Backend Deployment and Service

Save the following YAML as `backend-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: hashicorp/http-echo
        args:
          - "-text=Hello from the backend"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Apply the deployment and service:

```bash
kubectl apply -f backend-deployment.yaml
```

### Step 2: Deploy the Client Pods

Next, we'll deploy two client pods:

1. **`allowed-client`**: A pod that should be allowed to communicate with the `backend` service.
2. **`blocked-client`**: A pod that should be blocked from communicating with the `backend` service.

#### 2.1 Create the Allowed Client Pod

Save the following YAML as `allowed-client.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: allowed-client
  labels:
    access: granted
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

Apply the allowed client pod:

```bash
kubectl apply -f allowed-client.yaml
```

#### 2.2 Create the Blocked Client Pod

Save the following YAML as `blocked-client.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: blocked-client
  labels:
    access: denied
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

Apply the blocked client pod:

```bash
kubectl apply -f blocked-client.yaml
```

### Step 3: Create the NetworkPolicy

Now, let's create a NetworkPolicy that only allows pods with the label `access: granted` to communicate with the `backend-service`.

Save the following YAML as `network-policy.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-selected-pods
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: granted
    ports:
    - protocol: TCP
      port: 80
```

This NetworkPolicy does the following:

- **`podSelector`**: Targets the pods with the label `app: backend`, which in this case is the `backend` service.
- **`policyTypes`**: Specifies that this policy is for ingress traffic.
- **`ingress`**: Allows traffic only from pods with the label `access: granted`.

Apply the NetworkPolicy:

```bash
kubectl apply -f network-policy.yaml
```

### Step 4: Test the NetworkPolicy

#### 4.1 Test Allowed Traffic

To test that the `allowed-client` can communicate with the `backend-service`, exec into the `allowed-client` pod and try to access the `backend-service`:

```bash
kubectl exec -it allowed-client -- wget --spider --timeout=5 backend-service
```

If the NetworkPolicy is configured correctly, this command should succeed, indicating that the `allowed-client` pod can reach the `backend-service`.

#### 4.2 Test Blocked Traffic

Next, test that the `blocked-client` cannot communicate with the `backend-service`:

```bash
kubectl exec -it blocked-client -- wget --spider --timeout=5 backend-service
```

This command should fail, indicating that the `blocked-client` pod cannot reach the `backend-service`.

### Step 5: Clean Up

Once you've verified the NetworkPolicy works as expected, you can clean up the resources:

```bash
kubectl delete pod allowed-client blocked-client
kubectl delete deployment backend
kubectl delete service backend-service
kubectl delete networkpolicy allow-selected-pods
```

### Official Resources

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)


**Set up an Ingress controller and configure an Ingress resource to route traffic to multiple backend services based on URL path rules. Validate that requests are routed correctly.**

### Step 1: Set Up the Ingress Controller

To route traffic using an Ingress resource, you first need to deploy an Ingress controller in your Kubernetes cluster. The NGINX Ingress Controller is a popular choice, and we'll use it in this example.

#### 1.1 Deploy the NGINX Ingress Controller using Helm (Recommended)

If you have Helm installed, you can deploy the NGINX Ingress Controller with the following commands:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx
```

#### 1.2 Deploy the NGINX Ingress Controller Manually

If you prefer to deploy the NGINX Ingress Controller manually, you can apply the official YAML manifest:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

#### 1.3 Verify the Ingress Controller Deployment

To verify that the Ingress controller is running, check the pods in the namespace where it was deployed (usually `ingress-nginx`):

```bash
kubectl get pods -n ingress-nginx
```

You should see one or more `nginx-ingress-controller` pods running.

### Step 2: Deploy Backend Services

Next, deploy two backend services (`app1` and `app2`) that will be routed based on URL path rules.

#### 2.1 Deploy `app1`

Create a deployment and service for `app1`. Save the following YAML as `app1-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: hashicorp/http-echo
        args:
          - "-text=Hello from App1"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  selector:
    app: app1
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Apply the deployment and service:

```bash
kubectl apply -f app1-deployment.yaml
```

#### 2.2 Deploy `app2`

Similarly, create a deployment and service for `app2`. Save the following YAML as `app2-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: hashicorp/http-echo
        args:
          - "-text=Hello from App2"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: app2-service
spec:
  selector:
    app: app2
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Apply the deployment and service:

```bash
kubectl apply -f app2-deployment.yaml
```

### Step 3: Create the Ingress Resource

Now, create an Ingress resource that routes traffic to `app1` and `app2` based on the URL path.

#### 3.1 Create the Ingress Resource

Save the following YAML as `ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: yourdomain.com  # Replace with your actual domain
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

This Ingress resource does the following:

- **`host`**: Specifies the domain under which the paths `/app1` and `/app2` will be routed.
- **`paths`**: Defines the paths `/app1` and `/app2` and maps them to the respective services (`app1-service` and `app2-service`).
- **`nginx.ingress.kubernetes.io/rewrite-target: /`**: Ensures that the requests are correctly routed to the services without retaining the path prefix.

Apply the Ingress configuration:

```bash
kubectl apply -f ingress.yaml
```

### Step 4: Validate the Ingress Configuration

#### 4.1 Check the Ingress Resource

Verify that the Ingress resource was created:

```bash
kubectl get ingress app-ingress
```

You should see output similar to this:

```
NAME          CLASS    HOSTS             ADDRESS          PORTS     AGE
app-ingress   <none>   yourdomain.com    <external-ip>    80        10s
```

#### 4.2 Test Access to the Applications

To test the routing, you can use `curl` or a web browser to access the following URLs:

- **Access `app1`**:

  ```bash
  curl http://yourdomain.com/app1
  ```

  You should see the response:

  ```
  Hello from App1
  ```

- **Access `app2`**:

  ```bash
  curl http://yourdomain.com/app2
  ```

  You should see the response:

  ```
  Hello from App2
  ```

If you don’t have a domain name, you can simulate it by editing your `/etc/hosts` file (on Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (on Windows) and adding an entry like this:

```
<external-ip-of-ingress-controller>   yourdomain.com
```

### Step 5: Troubleshoot Connectivity Issues

If you experience issues while accessing the applications:

1. **Check Ingress Controller Logs**:

   If you're using NGINX Ingress Controller, check the logs to identify any issues:

   ```bash
   kubectl logs -n ingress-nginx <nginx-ingress-controller-pod>
   ```

2. **Verify DNS Settings**:

   Ensure that your domain name resolves to the correct IP address of the Ingress controller.

3. **Test Direct Service Access**:

   Bypass the Ingress by port-forwarding directly to the service to ensure the service is working:

   ```bash
   kubectl port-forward svc/app1-service 8080:80
   ```

   Then, access it via `http://localhost:8080`.

4. **Check Network Policies**:

   If you’re using NetworkPolicies, ensure they allow traffic to the services from the Ingress controller.

### Step 6: Clean Up

Once you've finished testing, clean up the resources:

```bash
kubectl delete deployment app1 app2
kubectl delete service app1-service app2-service
kubectl delete ingress app-ingress
```

### Official Resources

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)


**Deploy a NodePort service to expose an application externally. Test external access to the application from a web browser or curl command.**

### Step 1: Deploy the Application

First, let's deploy an application that we want to expose externally using a NodePort service. We'll use a simple NGINX deployment as an example.

#### 1.1 Create the Deployment

Save the following YAML as `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the deployment:

```bash
kubectl apply -f nginx-deployment.yaml
```

### Step 2: Create the NodePort Service

Next, create a NodePort service to expose the NGINX deployment externally.

#### 2.1 Create the NodePort Service

Save the following YAML as `nginx-nodeport-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080  # Optional: Specify a custom NodePort, or let Kubernetes assign one.
```

This configuration does the following:

- **`type: NodePort`**: Exposes the service on a port on each node in the cluster.
- **`port: 80`**: The port that the service will expose.
- **`targetPort: 80`**: The port on the pod that the service should forward traffic to.
- **`nodePort: 30080`**: The NodePort that the service will be exposed on. This is optional; if you don’t specify it, Kubernetes will automatically assign a port between 30000-32767.

Apply the service:

```bash
kubectl apply -f nginx-nodeport-service.yaml
```

### Step 3: Verify the NodePort Service

#### 3.1 Get the Service Details

Check the details of the service to ensure it has been created and is using the correct NodePort:

```bash
kubectl get svc nginx-service
```

You should see output similar to this:

```
NAME            TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
nginx-service   NodePort   10.100.200.201   <none>        80:30080/TCP   10s
```

- **`30080`** is the NodePort that you will use to access the application externally.

#### 3.2 Get the External IP of a Node

To access the application from outside the cluster, you need to know the external IP address of one of your cluster nodes. You can get this with the following command:

```bash
kubectl get nodes -o wide
```

Look for the `EXTERNAL-IP` of any node. If you're running a local cluster (e.g., Minikube or Docker Desktop), the external IP might be the same as your machine’s IP address.

### Step 4: Access the Application Externally

Now that the NodePort service is set up, you can access the NGINX application externally.

#### 4.1 Access the Application via Web Browser

Open a web browser and navigate to:

```
http://<node-external-ip>:30080
```

Replace `<node-external-ip>` with the actual external IP address of the node. You should see the default NGINX welcome page.

#### 4.2 Access the Application via Curl

Alternatively, you can use `curl` to access the application from the command line:

```bash
curl http://<node-external-ip>:30080
```

You should see the HTML content of the NGINX welcome page.

### Step 5: Troubleshoot Connectivity Issues

If you experience any issues while accessing the application:

1. **Check the NodePort Service:**

   Ensure that the NodePort service is correctly configured and that the NodePort is open:

   ```bash
   kubectl get svc nginx-service
   ```

2. **Verify Node Accessibility:**

   Ensure that the node’s external IP is accessible from your network. Check that firewall rules or security groups allow traffic to the NodePort (e.g., `30080`).

3. **Test Locally:**

   If testing remotely isn’t working, try port-forwarding as a workaround to verify the application:

   ```bash
   kubectl port-forward svc/nginx-service 8080:80
   ```

   Then access the application at `http://localhost:8080`.

4. **Check Logs:**

   If the service is running but not responding as expected, check the logs of the NGINX pod:

   ```bash
   kubectl logs deployment/nginx-deployment
   ```

### Step 6: Clean Up

Once you’ve finished testing, clean up the resources:

```bash
kubectl delete service nginx-service
kubectl delete deployment nginx-deployment
```

### Official Resources

- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)


**Create an Ingress resource with basic authentication configured using an auth-secret. Validate the authentication by accessing the service via a web browser.**

To create an Ingress resource with basic authentication using an `auth-secret`, follow these steps:

### Step 1: Deploy the Application

First, deploy a simple application that we can expose through the Ingress. We'll use a basic NGINX deployment as an example.

#### 1.1 Create the Deployment

Save the following YAML as `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the deployment:

```bash
kubectl apply -f nginx-deployment.yaml
```

#### 1.2 Create the Service

Next, expose the deployment using a ClusterIP service:

Save the following YAML as `nginx-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

Apply the service:

```bash
kubectl apply -f nginx-service.yaml
```

### Step 2: Create the Basic Authentication Secret

#### 2.1 Generate the Basic Auth Credentials

First, generate a username and password combination encoded in the format required by NGINX. You can use the `htpasswd` command, which is available in the `apache2-utils` package on Linux or can be installed via Homebrew on macOS:

```bash
htpasswd -c auth myuser
```

This command will prompt you to create a password for `myuser` and generate a file named `auth` with the encoded credentials.

#### 2.2 Create the Kubernetes Secret

Create a Kubernetes secret using the generated `auth` file:

```bash
kubectl create secret generic auth-secret --from-file=auth
```

This command creates a secret named `auth-secret` in your Kubernetes cluster.

### Step 3: Create the Ingress Resource

Next, create the Ingress resource that uses basic authentication.

#### 3.1 Create the Ingress Resource

Save the following YAML as `nginx-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/auth-type: "basic"
    nginx.ingress.kubernetes.io/auth-secret: "auth-secret"
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required - NGINX"
spec:
  rules:
  - host: yourdomain.com  # Replace with your actual domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

This configuration:

- **`nginx.ingress.kubernetes.io/auth-type: "basic"`**: Enables basic authentication.
- **`nginx.ingress.kubernetes.io/auth-secret: "auth-secret"`**: Specifies the secret that contains the authentication credentials.
- **`nginx.ingress.kubernetes.io/auth-realm: "Authentication Required - NGINX"`**: Customizes the authentication prompt in the browser.

Apply the Ingress resource:

```bash
kubectl apply -f nginx-ingress.yaml
```

### Step 4: Validate the Ingress Configuration

#### 4.1 Check the Ingress Resource

Verify that the Ingress resource was created:

```bash
kubectl get ingress nginx-ingress
```

You should see output similar to this:

```
NAME            CLASS    HOSTS             ADDRESS          PORTS     AGE
nginx-ingress   <none>   yourdomain.com    <external-ip>    80        10s
```

#### 4.2 Test Access with Basic Authentication

1. **Update the Hosts File (if needed):**

   If you don't have a domain name, simulate one by editing your `/etc/hosts` file (on Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (on Windows) and add an entry like this:

   ```
   <external-ip-of-ingress-controller>   yourdomain.com
   ```

2. **Access the Application via Web Browser:**

   Open a web browser and navigate to:

   ```
   http://yourdomain.com
   ```

   You should be prompted for a username and password. Use the credentials you generated earlier (`myuser` and the password you set). Upon successful authentication, you should see the NGINX welcome page.

3. **Test with Curl:**

   You can also use `curl` to test the basic authentication:

   ```bash
   curl -u myuser:mypassword http://yourdomain.com
   ```

   Replace `mypassword` with the password you set. You should see the HTML content of the NGINX welcome page.

### Step 5: Troubleshoot Connectivity Issues

If you encounter issues while accessing the application:

1. **Check the Ingress Controller Logs:**

   If you're using NGINX Ingress Controller, check the logs to identify any issues:

   ```bash
   kubectl logs -n ingress-nginx <nginx-ingress-controller-pod>
   ```

2. **Verify the Secret:**

   Ensure that the `auth-secret` is correctly configured and associated with the Ingress resource.

3. **Check the Ingress Status:**

   Ensure the Ingress is pointing to the correct services and is correctly configured.

### Step 6: Clean Up

After testing, you can clean up the resources:

```bash
kubectl delete ingress nginx-ingress
kubectl delete secret auth-secret
kubectl delete service nginx-service
kubectl delete deployment nginx-deployment
```

### Official Resources

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)


**Set up a LoadBalancer service to expose an application to the internet. Verify that the service has an external IP and can handle incoming traffic.**

To set up a LoadBalancer service to expose an application to the internet, follow these steps:

### Step 1: Deploy the Application

First, you need to deploy the application that you want to expose via the LoadBalancer service. We will use a simple NGINX deployment as an example.

#### 1.1 Create the Deployment

Save the following YAML as `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Apply the deployment:

```bash
kubectl apply -f nginx-deployment.yaml
```

### Step 2: Create the LoadBalancer Service

Now, create a LoadBalancer service to expose the NGINX deployment externally.

#### 2.1 Create the LoadBalancer Service

Save the following YAML as `nginx-loadbalancer-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

This configuration does the following:

- **`type: LoadBalancer`**: Creates an external LoadBalancer that routes traffic to the backend pods.
- **`port: 80`**: The port that the service will expose.
- **`targetPort: 80`**: The port on the pod that the service should forward traffic to.

Apply the service:

```bash
kubectl apply -f nginx-loadbalancer-service.yaml
```

### Step 3: Verify the LoadBalancer Service

#### 3.1 Check the Service Details

Check the details of the service to ensure it has been created and is using the correct LoadBalancer type:

```bash
kubectl get svc nginx-loadbalancer
```

You should see output similar to this:

```
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
nginx-loadbalancer   LoadBalancer   10.96.138.251    <pending>        80:31382/TCP   10s
```

- **`EXTERNAL-IP`**: This field should eventually show the external IP address assigned to the LoadBalancer by your cloud provider. It may initially show as `<pending>` if the external IP is not yet assigned.

#### 3.2 Wait for the External IP to be Assigned

It may take a few minutes for the external IP to be provisioned by the cloud provider. Keep checking the status of the service until an external IP is assigned:

```bash
kubectl get svc nginx-loadbalancer --watch
```

Once the external IP is assigned, you should see something like this:

```
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
nginx-loadbalancer   LoadBalancer   10.96.138.251    203.0.113.123    80:31382/TCP   1m
```

#### 3.3 Test External Access to the Application

Once the external IP is assigned, you can access the NGINX application using the external IP.

1. **Access the Application via Web Browser:**

   Open a web browser and navigate to:

   ```
   http://203.0.113.123
   ```

   Replace `203.0.113.123` with the actual external IP assigned to your LoadBalancer. You should see the default NGINX welcome page.

2. **Access the Application via Curl:**

   You can also use `curl` to access the application from the command line:

   ```bash
   curl http://203.0.113.123
   ```

   You should see the HTML content of the NGINX welcome page.

### Step 4: Troubleshoot Connectivity Issues

If you experience issues while accessing the application:

1. **Check the LoadBalancer Service:**

   Ensure that the LoadBalancer service is correctly configured and that the external IP has been assigned:

   ```bash
   kubectl get svc nginx-loadbalancer
   ```

2. **Verify Node Accessibility:**

   Ensure that the external IP is accessible from your network. Check that any firewall rules or security groups allow traffic to port `80`.

3. **Test Locally:**

   If testing remotely isn’t working, try port-forwarding as a workaround to verify the application:

   ```bash
   kubectl port-forward svc/nginx-loadbalancer 8080:80
   ```

   Then access the application at `http://localhost:8080`.

4. **Check Logs:**

   If the service is running but not responding as expected, check the logs of the NGINX pod:

   ```bash
   kubectl logs deployment/nginx-deployment
   ```

### Step 5: Clean Up

Once you’ve finished testing, clean up the resources:

```bash
kubectl delete service nginx-loadbalancer
kubectl delete deployment nginx-deployment
```

### Official Resources

- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [LoadBalancer Service](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)


**Implement a headless service and StatefulSet to deploy a clustered application (e.g., Cassandra). Verify that the application nodes can discover and connect to each other.**

To implement a headless service and StatefulSet for deploying a clustered application like Cassandra, follow these steps:

### Step 1: Create the Headless Service

A headless service is used in Kubernetes to manage the network identities of pods in a StatefulSet. Unlike a regular service, a headless service does not have a cluster IP, and it allows the pods to be directly addressable by their DNS names.

#### 1.1 Create the Headless Service

Save the following YAML as `cassandra-headless-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: cassandra
  labels:
    app: cassandra
spec:
  ports:
  - port: 9042
    name: cql
  clusterIP: None  # Headless service
  selector:
    app: cassandra
```

This configuration:

- **`clusterIP: None`**: Makes the service headless.
- **`selector: app: cassandra`**: Selects the pods with the label `app: cassandra`.

Apply the headless service:

```bash
kubectl apply -f cassandra-headless-service.yaml
```

### Step 2: Create the StatefulSet

A StatefulSet manages the deployment and scaling of a set of pods and provides guarantees about the ordering and uniqueness of these pods, which is important for stateful applications like Cassandra.

#### 2.1 Create the StatefulSet

Save the following YAML as `cassandra-statefulset.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cassandra
  labels:
    app: cassandra
spec:
  serviceName: cassandra
  replicas: 3
  selector:
    matchLabels:
      app: cassandra
  template:
    metadata:
      labels:
        app: cassandra
    spec:
      containers:
      - name: cassandra
        image: cassandra:latest
        ports:
        - containerPort: 7000
          name: intra-node
        - containerPort: 7001
          name: tls-intra-node
        - containerPort: 7199
          name: jmx
        - containerPort: 9042
          name: cql
        env:
        - name: CASSANDRA_SEEDS
          value: "cassandra-0.cassandra,cassandra-1.cassandra,cassandra-2.cassandra"
        - name: CASSANDRA_CLUSTER_NAME
          value: "K8Demo"
        - name: CASSANDRA_DC
          value: "DC1"
        - name: CASSANDRA_RACK
          value: "Rack1"
        - name: CASSANDRA_ENDPOINT_SNITCH
          value: "GossipingPropertyFileSnitch"
        volumeMounts:
        - name: cassandra-data
          mountPath: /var/lib/cassandra
  volumeClaimTemplates:
  - metadata:
      name: cassandra-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"  # Use appropriate storage class
      resources:
        requests:
          storage: 10Gi
```

This configuration:

- **`serviceName: cassandra`**: Specifies the headless service to use.
- **`replicas: 3`**: Creates 3 replicas of the Cassandra pod, each with a unique network identity.
- **`CASSANDRA_SEEDS`**: Specifies the seed nodes for the cluster, which are used for bootstrapping the cluster.
- **`volumeClaimTemplates`**: Creates persistent storage for each Cassandra pod.

Apply the StatefulSet:

```bash
kubectl apply -f cassandra-statefulset.yaml
```

### Step 3: Verify the Cassandra Cluster

#### 3.1 Check the StatefulSet Pods

First, check that all Cassandra pods are running:

```bash
kubectl get pods -l app=cassandra
```

You should see output similar to:

```
NAME          READY   STATUS    RESTARTS   AGE
cassandra-0   1/1     Running   0          2m
cassandra-1   1/1     Running   0          2m
cassandra-2   1/1     Running   0          2m
```

Each pod should be in a `Running` state.

#### 3.2 Verify Cassandra Node Connectivity

To verify that the Cassandra nodes can discover and connect to each other, exec into one of the Cassandra pods and use the `nodetool status` command:

```bash
kubectl exec -it cassandra-0 -- nodetool status
```

You should see output that indicates all nodes in the cluster are up and running:

```
Datacenter: DC1
===================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address         Load       Tokens  Owns (effective)  Host ID                               Rack
UN  10.244.2.5      256 KB     256     66.7%             e1a1e2f2-fb3d-4b4b-8e4b-4f894b251e4c  Rack1
UN  10.244.2.6      256 KB     256     66.7%             22a2e2c3-3a3a-4b7a-9e7a-7b7e2b2c3c3c  Rack1
UN  10.244.2.7      256 KB     256     66.7%             33c3f3d4-4d4e-4e8a-8a8e-8e8e4e4f4f4f  Rack1
```

This indicates that the nodes have discovered each other and are connected as part of the same cluster.

### Step 4: Clean Up

Once you’ve finished testing, clean up the resources:

```bash
kubectl delete statefulset cassandra
kubectl delete service cassandra
kubectl delete pvc -l app=cassandra
```

### Official Resources

- [Kubernetes StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Kubernetes Headless Services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)
- [Cassandra Kubernetes Deployment](https://kubernetes.io/docs/tutorials/stateful-application/cassandra/)


**Use kubectl proxy to create a secure tunnel to access the Kubernetes API server and validate the access using curl or another HTTP client.**

### Step 1: Start `kubectl proxy`

`kubectl proxy` is a simple way to create a secure tunnel from your local machine to the Kubernetes API server. It runs a proxy server on your local machine and forwards API requests to the Kubernetes API server.

Start the `kubectl proxy`:

```bash
kubectl proxy --port=8080
```

This command will start the proxy on `localhost` at port `8080` by default.

You should see output like this:

```
Starting to serve on 127.0.0.1:8080
```

This means the proxy is running, and you can now send requests to the Kubernetes API server through it.

### Step 2: Access the Kubernetes API via the Proxy

Now that the proxy is running, you can access the Kubernetes API using `curl` or any other HTTP client. The API server will be available at `http://localhost:8080`.

#### 2.1 Get API Server Version

To verify that the proxy is working, you can query the API server’s version endpoint:

```bash
curl http://localhost:8080/api
```

You should get a response similar to this:

```json
{
  "kind": "APIVersions",
  "versions": [
    "v1",
    "admissionregistration.k8s.io/v1",
    "admissionregistration.k8s.io/v1beta1",
    "apps/v1",
    ...
  ],
  "serverAddressByClientCIDRs": null
}
```

This indicates that your request was successfully forwarded to the Kubernetes API server and that the API server is responding.

#### 2.2 List Pods in the Default Namespace

You can also use `curl` to interact with the Kubernetes API, such as listing all pods in the default namespace:

```bash
curl http://localhost:8080/api/v1/namespaces/default/pods
```

You should get a JSON response listing the pods in the default namespace:

```json
{
  "kind": "PodList",
  "apiVersion": "v1",
  "items": [
    {
      "metadata": {
        "name": "example-pod",
        "namespace": "default",
        ...
      },
      ...
    },
    ...
  ]
}
```

This response shows the metadata and status of each pod in the default namespace.

### Step 3: Validate Access with an HTTP Client

If you prefer using an HTTP client like Postman, you can perform the same requests by pointing the client to `http://localhost:8080` and making requests to the desired API endpoints.

For example, in Postman:

1. Set the request method to `GET`.
2. Enter the URL: `http://localhost:8080/api/v1/namespaces/default/pods`.
3. Send the request.
4. You should see the JSON response with the list of pods.

### Step 4: Stop the Proxy

When you’re done, you can stop the `kubectl proxy` by pressing `Ctrl+C` in the terminal where it’s running.

### Summary

Using `kubectl proxy` is a secure and straightforward way to interact with the Kubernetes API server locally without needing direct access to the API server. This method is particularly useful for testing and local development scenarios.

### Official Kubernetes Resources

- [Accessing the Kubernetes API](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/)
- [kubectl proxy](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#proxy)

**Set up a ClusterIP service with session affinity enabled. Test the service to ensure that client requests are consistently routed to the same pod.**

### Step 1: Deploy an Application

First, deploy an application that we can expose through a ClusterIP service with session affinity. We'll use a simple NGINX deployment as an example.

#### 1.1 Create the Deployment

Save the following YAML as `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        env:
        - name: HOSTNAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
```

This deployment creates 3 replicas of an NGINX server, and each pod will have its hostname set to its pod name, which we'll use to verify session affinity.

Apply the deployment:

```bash
kubectl apply -f nginx-deployment.yaml
```

### Step 2: Create a ClusterIP Service with Session Affinity

Next, create a ClusterIP service that exposes the NGINX deployment and enables session affinity.

#### 2.1 Create the Service

Save the following YAML as `nginx-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  sessionAffinity: ClientIP
```

This configuration:

- **`sessionAffinity: ClientIP`**: Ensures that requests from the same client IP are consistently routed to the same pod.

Apply the service:

```bash
kubectl apply -f nginx-service.yaml
```

### Step 3: Test the Session Affinity

#### 3.1 Get the ClusterIP of the Service

First, get the ClusterIP of the service:

```bash
kubectl get svc nginx-service
```

You should see output similar to this:

```
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
nginx-service   ClusterIP   10.96.78.250   <none>        80/TCP    1m
```

Take note of the `CLUSTER-IP` value (e.g., `10.96.78.250`), which will be used to test the service.

#### 3.2 Test with Curl

To test session affinity, you can use `curl` in a loop to make repeated requests to the service. Run the following command:

```bash
for i in {1..10}; do curl -s http://<CLUSTER-IP>/ | grep "Server"; done
```

Replace `<CLUSTER-IP>` with the actual ClusterIP of the service.

This command sends 10 requests to the service and prints the `Server` header (which contains the pod's hostname) from the response. If session affinity is working correctly, you should see the same pod's hostname repeated in all the outputs.

Example output:

```
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
Server: nginx-deployment-7c9c7c4d6f-abcde
```

If the session affinity is not working correctly, you will see different pod names in the output.

### Step 4: Clean Up

Once you've verified that session affinity is working, you can clean up the resources:

```bash
kubectl delete svc nginx-service
kubectl delete deployment nginx-deployment
```

### Official Resources

- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Session Affinity](https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service)


**Create and troubleshoot an Ingress resource with a wildcard SSL certificate to serve multiple subdomains securely. Verify that all subdomains are accessible via HTTPS.**

To create and troubleshoot an Ingress resource with a wildcard SSL certificate for serving multiple subdomains securely, follow these steps:

### Step 1: Obtain a Wildcard SSL Certificate

First, you need to obtain a wildcard SSL certificate for your domain. This certificate should cover all subdomains, for example, `*.example.com`.

You can generate a self-signed wildcard SSL certificate using OpenSSL for testing purposes:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout wildcard.example.com.key \
  -out wildcard.example.com.crt \
  -subj "/CN=*.example.com"
```

This command generates a wildcard certificate and key for `*.example.com`.

### Step 2: Create a Kubernetes Secret for the SSL Certificate

Next, create a Kubernetes Secret to store the SSL certificate and key:

```bash
kubectl create secret tls wildcard-tls-secret --cert=wildcard.example.com.crt --key=wildcard.example.com.key
```

This secret will be used by the Ingress resource to terminate SSL.

### Step 3: Deploy Example Applications

Deploy multiple example applications that will serve different subdomains. For this example, we'll deploy two applications: `app1` and `app2`.

#### 3.1 Deploy `app1`

Save the following YAML as `app1-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: hashicorp/http-echo
        args:
          - "-text=Hello from App1"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  selector:
    app: app1
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Apply the deployment and service:

```bash
kubectl apply -f app1-deployment.yaml
```

#### 3.2 Deploy `app2`

Similarly, save the following YAML as `app2-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: hashicorp/http-echo
        args:
          - "-text=Hello from App2"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: app2-service
spec:
  selector:
    app: app2
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Apply the deployment and service:

```bash
kubectl apply -f app2-deployment.yaml
```

### Step 4: Create the Ingress Resource

Now, create an Ingress resource that uses the wildcard SSL certificate to serve the applications on different subdomains.

#### 4.1 Create the Ingress Resource

Save the following YAML as `ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  labels:
    app: example
spec:
  tls:
  - hosts:
    - "*.example.com"
    secretName: wildcard-tls-secret
  rules:
  - host: app1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

This configuration:

- **`tls`**: Specifies that the Ingress should use the wildcard SSL certificate stored in `wildcard-tls-secret`.
- **`rules`**: Defines the routing rules, routing `app1.example.com` to `app1-service` and `app2.example.com` to `app2-service`.

Apply the Ingress configuration:

```bash
kubectl apply -f ingress.yaml
```

### Step 5: Validate HTTPS Access

#### 5.1 Check the Ingress Resource

Verify that the Ingress resource was created successfully:

```bash
kubectl get ingress example-ingress
```

You should see output showing that the Ingress is configured with the correct hosts and TLS information.

#### 5.2 Test Access to Subdomains

To test the Ingress resource:

1. **Update `/etc/hosts` (if testing locally):**

   If you are testing locally and don't have DNS set up for `example.com`, edit your `/etc/hosts` file (on Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (on Windows) and add entries like this:

   ```
   <external-ip-of-ingress-controller>   app1.example.com
   <external-ip-of-ingress-controller>   app2.example.com
   ```

2. **Access `app1` via HTTPS:**

   Open a web browser and navigate to:

   ```
   https://app1.example.com
   ```

   You should see the response `Hello from App1` served securely over HTTPS.

3. **Access `app2` via HTTPS:**

   Similarly, navigate to:

   ```
   https://app2.example.com
   ```

   You should see the response `Hello from App2` served securely over HTTPS.

### Step 6: Troubleshoot Connectivity Issues

If you encounter issues:

1. **Check Ingress Controller Logs:**

   ```bash
   kubectl logs -n <ingress-controller-namespace> <ingress-controller-pod>
   ```

   Look for any errors or issues related to SSL or routing.

2. **Verify DNS/Hosts Configuration:**

   Ensure that `app1.example.com` and `app2.example.com` resolve to the external IP of the Ingress controller.

3. **Check SSL Certificate:**

   Use a tool like `openssl` to verify that the correct wildcard certificate is being served:

   ```bash
   openssl s_client -connect app1.example.com:443 -servername app1.example.com
   ```

   Look for the certificate details in the output to ensure the wildcard certificate is being used.

4. **Verify Pod and Service Status:**

   Ensure that the backend pods are running and the services are correctly exposing the applications:

   ```bash
   kubectl get pods -l app=app1
   kubectl get pods -l app=app2
   kubectl get svc app1-service
   kubectl get svc app2-service
   ```

### Step 7: Clean Up

Once you've finished testing, clean up the resources:

```bash
kubectl delete ingress example-ingress
kubectl delete secret wildcard-tls-secret
kubectl delete service app1-service app2-service
kubectl delete deployment app1 app2
```

### Official Resources

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Kubernetes TLS Secrets](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)

