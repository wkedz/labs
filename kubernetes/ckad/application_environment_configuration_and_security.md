---
id: 2024-09-17-08:23-application_environment_configuration_and_security
aliases: []
tags:
  - k8s
  - ckad
date: "2024-09-17"
title: application_environment_configuration_and_security
---

# application_environment_configuration_and_security

**Create a ConfigMap and a Secret to manage configuration data and sensitive information for a Deployment. Use environment variables to inject the ConfigMap and Secret into the application containers. Verify the application consumes the configuration correctly.**

### Step 1: Create the ConfigMap

First, create a ConfigMap to hold non-sensitive configuration data. Save the following YAML as `app-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: "production"
  APP_DEBUG: "false"
  APP_VERSION: "1.0.0"
```

### Step 2: Create the Secret

Next, create a Secret to store sensitive information. Save the following YAML as `app-secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_USERNAME: dXNlcm5hbWU=   # Base64 encoded value of 'username'
  DB_PASSWORD: cGFzc3dvcmQ=   # Base64 encoded value of 'password'
```

To encode the values using base64, you can use the following command:

```bash
echo -n 'username' | base64
echo -n 'password' | base64
```

### Step 3: Create the Deployment

Now, create a Deployment that injects the ConfigMap and Secret as environment variables into the application container. Save the following YAML as `app-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
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
        image: nginx:latest
        env:
        - name: APP_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_ENV
        - name: APP_DEBUG
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_DEBUG
        - name: APP_VERSION
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: APP_VERSION
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: DB_USERNAME
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: DB_PASSWORD
```

### Step 4: Apply the ConfigMap, Secret, and Deployment

Use the following commands to create the ConfigMap, Secret, and Deployment in your Kubernetes cluster:

```bash
kubectl apply -f app-configmap.yaml
kubectl apply -f app-secret.yaml
kubectl apply -f app-deployment.yaml
```

### Step 5: Verify the Application Consumes the Configuration Correctly

1. **Check the environment variables inside the running pod:**

   Get the pod name:

   ```bash
   kubectl get pods -l app=myapp
   ```

   Exec into the pod:

   ```bash
   kubectl exec -it <pod-name> -- env
   ```

   Replace `<pod-name>` with the actual name of your pod. Check that the environment variables (`APP_ENV`, `APP_DEBUG`, `APP_VERSION`, `DB_USERNAME`, `DB_PASSWORD`) are correctly set.

### Official Kubernetes Resources

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)


**Create a Custom Resource Definition (CRD) and an associated Operator that manages a custom resource type in Kubernetes. Deploy the Operator and demonstrate creating and managing custom resources.**

### Step 1: Create the Custom Resource Definition (CRD)

First, create the CRD to define your custom resource. Save the following YAML as `myresource-crd.yaml`:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: myresources.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              name:
                type: string
              replicas:
                type: integer
    subresources:
      status: {}
  scope: Namespaced
  names:
    plural: myresources
    singular: myresource
    kind: MyResource
    shortNames:
    - myres
```

### Step 2: Deploy the CRD

Apply the CRD to your Kubernetes cluster:

```bash
kubectl apply -f myresource-crd.yaml
```

### Step 3: Create the Operator

Here’s an example of a basic Operator using a simple shell script in a Deployment that manages the custom resource. Save the following YAML as `myresource-operator.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myresource-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myresource-operator
  template:
    metadata:
      labels:
        app: myresource-operator
    spec:
      containers:
      - name: operator
        image: busybox
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            for res in $(kubectl get myresources.example.com -o jsonpath='{.items[*].metadata.name}'); do
              spec=$(kubectl get myresource $res -o jsonpath='{.spec}')
              echo "Managing MyResource: $res with spec: $spec"
              # Perform actions based on the spec, such as scaling Deployments
            done
            sleep 30
          done
```

### Step 4: Deploy the Operator

Apply the Operator Deployment to your Kubernetes cluster:

```bash
kubectl apply -f myresource-operator.yaml
```

### Step 5: Create a Custom Resource

Create a custom resource to be managed by the Operator. Save the following YAML as `myresource-instance.yaml`:

```yaml
apiVersion: example.com/v1
kind: MyResource
metadata:
  name: myresource-sample
spec:
  name: "example-resource"
  replicas: 3
```

Apply the custom resource:

```bash
kubectl apply -f myresource-instance.yaml
```

### Step 6: Verify the Operator is Managing the Custom Resource

Check the logs of the Operator pod to verify it’s managing the custom resource:

```bash
kubectl logs -l app=myresource-operator
```

You should see output similar to:

```
Managing MyResource: myresource-sample with spec: map[name:example-resource replicas:3]
```

### Official Kubernetes Resources

- [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [Developing an Operator](https://kubernetes.io/docs/tasks/extend-kubernetes/operator/)


**Set up RBAC rules that restrict access to a specific namespace to only allow viewing resources. Test these permissions with a ServiceAccount and verify that it adheres to the rules.**

### Step 1: Create a Namespace

First, create a namespace where you will apply the RBAC rules. Save the following YAML as `view-namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: restricted-namespace
```

Apply the namespace:

```bash
kubectl apply -f view-namespace.yaml
```

### Step 2: Create a ServiceAccount

Next, create a ServiceAccount that will be used to test the RBAC rules. Save the following YAML as `view-serviceaccount.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: view-sa
  namespace: restricted-namespace
```

Apply the ServiceAccount:

```bash
kubectl apply -f view-serviceaccount.yaml
```

### Step 3: Create a Role with View-Only Permissions

Create a Role that allows viewing resources in the specific namespace. Save the following YAML as `view-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: restricted-namespace
  name: view-role
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
```

Apply the Role:

```bash
kubectl apply -f view-role.yaml
```

### Step 4: Bind the Role to the ServiceAccount

Bind the Role to the ServiceAccount using a RoleBinding. Save the following YAML as `view-rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: view-rolebinding
  namespace: restricted-namespace
subjects:
- kind: ServiceAccount
  name: view-sa
  namespace: restricted-namespace
roleRef:
  kind: Role
  name: view-role
  apiGroup: rbac.authorization.k8s.io
```

Apply the RoleBinding:

```bash
kubectl apply -f view-rolebinding.yaml
```

### Step 5: Test the Permissions with the ServiceAccount

To test the permissions, use the following commands:

1. **Create a Pod to interact with the cluster using the ServiceAccount:**

   Save the following YAML as `test-pod.yaml`:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-pod
     namespace: restricted-namespace
   spec:
     serviceAccountName: view-sa
     containers:
     - name: test-container
       image: bitnami/kubectl:latest
       command: ["sleep", "3600"]
   ```

   Apply the test pod:

   ```bash
   kubectl apply -f test-pod.yaml
   ```

2. **Exec into the Pod and test permissions:**

   Exec into the pod:

   ```bash
   kubectl exec -it test-pod -n restricted-namespace -- sh
   ```

   Inside the pod, run commands to test permissions:

   ```sh
   kubectl get pods -n restricted-namespace    # Should succeed
   kubectl get services -n restricted-namespace # Should succeed
   kubectl delete pod <some-pod> -n restricted-namespace # Should fail
   ```

3. **Verify the ServiceAccount has limited access:**

   The `get`, `list`, and `watch` commands should succeed, while any `create`, `update`, or `delete` actions should fail, confirming the view-only access.

### Official Kubernetes Resources

- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [ServiceAccounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [Role and RoleBinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-rolebinding)


**Deploy an application that runs with elevated privileges, then modify the SecurityContext to drop unnecessary capabilities and run as a non-root user. Validate the changes and ensure the application functions correctly without elevated privileges.**

### Step 1: Deploy the Application with Elevated Privileges

First, deploy a simple application with elevated privileges. Save the following YAML as `privileged-app.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-app
spec:
  containers:
  - name: myapp
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      allowPrivilegeEscalation: true
      privileged: true
```

Apply the Pod:

```bash
kubectl apply -f privileged-app.yaml
```

### Step 2: Modify the SecurityContext to Drop Capabilities and Run as Non-Root

Now, modify the SecurityContext to drop unnecessary capabilities and ensure the application runs as a non-root user. Save the updated YAML as `non-privileged-app.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: non-privileged-app
spec:
  containers:
  - name: myapp
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
```

Apply the updated Pod:

```bash
kubectl apply -f non-privileged-app.yaml
```

### Step 3: Validate the SecurityContext Changes

1. **Check the SecurityContext of the Running Pod:**

   Verify that the Pod is running with the new SecurityContext settings:

   ```bash
   kubectl get pod non-privileged-app -o yaml | grep -A 10 securityContext
   ```

   You should see the `allowPrivilegeEscalation: false`, `runAsNonRoot: true`, `runAsUser: 1000`, and dropped capabilities in the output.

2. **Exec into the Pod to Check the User and Capabilities:**

   Exec into the running pod:

   ```bash
   kubectl exec -it non-privileged-app -- sh
   ```

   Inside the pod, run the following commands:

   ```sh
   id   # Verify that the user is not root (should show UID 1000)
   cat /proc/1/status | grep Cap   # Check the capabilities (should be dropped)
   ```

   The `id` command should show a non-root user, and the capabilities should be minimal or empty.

3. **Ensure the Application Functions Correctly:**

   Ensure that the application can still perform its intended function without the elevated privileges. If your application writes to a directory or interacts with certain files, make sure those paths have the appropriate permissions for the non-root user.

### Step 4: Clean Up

After validation, you can delete the Pods:

```bash
kubectl delete pod privileged-app
kubectl delete pod non-privileged-app
```

### Official Kubernetes Resources

- [SecurityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [Pod Security Policies](https://kubernetes.io/docs/concepts/security/pod-security-policy/)
- [Best Practices for Running Containers as Non-Root](https://kubernetes.io/docs/concepts/security/security-best-practices/#pod-security-context)

**Set up an Operator that manages a custom resource in Kubernetes. Deploy the Operator and create an instance of the custom resource to test its functionality.**

### Step 1: Create the Custom Resource Definition (CRD)

First, create the Custom Resource Definition (CRD) that the Operator will manage. Save the following YAML as `sample-crd.yaml`:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: samples.example.com
spec:
  group: example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              size:
                type: integer
    subresources:
      status: {}
  scope: Namespaced
  names:
    plural: samples
    singular: sample
    kind: Sample
    shortNames:
    - smpl
```

Apply the CRD to your cluster:

```bash
kubectl apply -f sample-crd.yaml
```

### Step 2: Develop the Operator

This example uses a simple Operator that creates or scales a Deployment based on the `size` field of the custom resource. Save the following YAML as `sample-operator.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-operator
  labels:
    app: sample-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-operator
  template:
    metadata:
      labels:
        app: sample-operator
    spec:
      containers:
      - name: operator
        image: busybox
        command: ["/bin/sh", "-c"]
        args:
          - |
            while true; do
              for cr in $(kubectl get samples.example.com -o jsonpath='{.items[*].metadata.name}'); do
                size=$(kubectl get sample $cr -o jsonpath='{.spec.size}');
                kubectl get deployment $cr 2>/dev/null;
                if [ $? -eq 0 ]; then
                  kubectl scale deployment $cr --replicas=$size;
                else
                  kubectl create deployment $cr --image=nginx;
                  kubectl scale deployment $cr --replicas=$size;
                fi;
              done;
              sleep 10;
            done;
```

Apply the Operator:

```bash
kubectl apply -f sample-operator.yaml
```

### Step 3: Create a Custom Resource

Create an instance of the custom resource to test the Operator’s functionality. Save the following YAML as `sample-resource.yaml`:

```yaml
apiVersion: example.com/v1
kind: Sample
metadata:
  name: my-sample
spec:
  size: 3
```

Apply the custom resource:

```bash
kubectl apply -f sample-resource.yaml
```

### Step 4: Validate the Operator

1. **Check the Deployment Managed by the Operator:**

   Verify that the Operator created and scaled the deployment:

   ```bash
   kubectl get deployments my-sample
   ```

   The output should show a Deployment named `my-sample` with 3 replicas.

2. **Change the Size and Validate:**

   Modify the custom resource to scale the deployment:

   ```bash
   kubectl patch sample my-sample --type='merge' -p '{"spec":{"size":5}}'
   ```

   Check that the Deployment has scaled to 5 replicas:

   ```bash
   kubectl get deployments my-sample
   ```

   The output should show that the number of replicas has been updated to 5.

### Step 5: Clean Up

To clean up the resources created during this process:

```bash
kubectl delete -f sample-resource.yaml
kubectl delete deployment sample-operator
kubectl delete crd samples.example.com
```

### Official Kubernetes Resources

- [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [Kubernetes Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [Developing an Operator](https://kubernetes.io/docs/tasks/extend-kubernetes/operator/)


**Configure a pod with a SecurityContext that disables privilege escalation, runs as a non-root user, and has read-only root filesystem. Validate the security settings.**

### Step 1: Create the Pod with SecurityContext

First, create a YAML file for the Pod with the specified security settings. Save the following YAML as `secure-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  containers:
  - name: secure-container
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      readOnlyRootFilesystem: true
```

### Step 2: Deploy the Pod

Apply the YAML to deploy the Pod:

```bash
kubectl apply -f secure-pod.yaml
```

### Step 3: Validate the Security Settings

1. **Check the Pod's SecurityContext:**

   Verify the Pod is running with the correct security settings:

   ```bash
   kubectl get pod secure-pod -o yaml | grep -A 10 securityContext
   ```

   You should see output confirming that `allowPrivilegeEscalation`, `runAsNonRoot`, `runAsUser`, and `readOnlyRootFilesystem` are set as expected.

2. **Exec into the Pod and Validate User and Filesystem:**

   Exec into the running Pod:

   ```bash
   kubectl exec -it secure-pod -- sh
   ```

   Inside the Pod, run the following commands:

   - **Check the User:**

     ```sh
     id
     ```

     The output should show a non-root user (UID 1000).

   - **Attempt to Write to the Root Filesystem:**

     ```sh
     touch /testfile
     ```

     This should fail with a "Read-only file system" error, confirming that the root filesystem is read-only.

   - **Check Privilege Escalation:**

     Attempt to use a command that requires elevated privileges, such as:

     ```sh
     su
     ```

     This should fail, confirming that privilege escalation is disabled.

### Step 4: Clean Up

After validation, you can delete the Pod:

```bash
kubectl delete pod secure-pod
```

### Official Kubernetes Resources

- [Pod Security Context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [Security Best Practices](https://kubernetes.io/docs/concepts/security/security-best-practices/)


**Create and apply a NetworkPolicy that restricts ingress traffic to a specific pod based on labels. Test the policy by attempting to connect from various sources.**

### Step 1: Label the Target Pod

First, create a pod and label it so that it can be targeted by the NetworkPolicy. Save the following YAML as `app-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: nginx:latest
    ports:
    - containerPort: 80
```

Apply the pod:

```bash
kubectl apply -f app-pod.yaml
```

### Step 2: Create the NetworkPolicy

Create a NetworkPolicy that restricts ingress traffic to the pod based on its labels. Save the following YAML as `restrict-ingress-policy.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-ingress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          access: allowed
    ports:
    - protocol: TCP
      port: 80
```

This NetworkPolicy allows ingress traffic only from pods with the label `access: allowed` to the pod labeled `app: myapp` on port 80.

Apply the NetworkPolicy:

```bash
kubectl apply -f restrict-ingress-policy.yaml
```

### Step 3: Test the NetworkPolicy

1. **Create a Pod that Should Have Access:**

   Create a pod with the label `access: allowed` to test allowed ingress. Save the following YAML as `allowed-pod.yaml`:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: allowed-pod
     labels:
       access: allowed
   spec:
     containers:
     - name: test-container
       image: busybox
       command: ["sh", "-c", "sleep 3600"]
   ```

   Apply the pod:

   ```bash
   kubectl apply -f allowed-pod.yaml
   ```

   Test connectivity from the `allowed-pod`:

   ```bash
   kubectl exec -it allowed-pod -- wget --spider --timeout=1 my-app-pod
   ```

   The connection should succeed.

2. **Create a Pod that Should Be Denied Access:**

   Create another pod without the `access: allowed` label. Save the following YAML as `denied-pod.yaml`:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: denied-pod
   spec:
     containers:
     - name: test-container
       image: busybox
       command: ["sh", "-c", "sleep 3600"]
   ```

   Apply the pod:

   ```bash
   kubectl apply -f denied-pod.yaml
   ```

   Test connectivity from the `denied-pod`:

   ```bash
   kubectl exec -it denied-pod -- wget --spider --timeout=1 my-app-pod
   ```

   The connection should fail, demonstrating that the NetworkPolicy is correctly restricting traffic.

### Step 4: Clean Up

After testing, clean up the resources:

```bash
kubectl delete pod my-app-pod allowed-pod denied-pod
kubectl delete networkpolicy restrict-ingress
```

### Official Kubernetes Resources

- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [NetworkPolicy API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#networkpolicy-v1-networking-k8s-io)


**Set up a ConfigMap and inject its data into a pod using volume mounts. Verify that the application reads configuration data from the mounted files.**

### Step 1: Create the ConfigMap

First, create a ConfigMap that contains the configuration data. Save the following YAML as `app-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.properties: |
    app.name=MyApp
    app.version=1.0.0
  logging.properties: |
    log.level=INFO
    log.output=stdout
```

Apply the ConfigMap:

```bash
kubectl apply -f app-configmap.yaml
```

### Step 2: Create the Pod with a Volume Mount for the ConfigMap

Next, create a pod that mounts the ConfigMap as a volume. Save the following YAML as `app-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

Apply the pod:

```bash
kubectl apply -f app-pod.yaml
```

### Step 3: Verify the Application Reads Configuration Data from the Mounted Files

1. **Check the contents of the mounted files:**

   Exec into the running pod:

   ```bash
   kubectl exec -it configmap-pod -- sh
   ```

   Inside the pod, list the contents of the `/etc/config` directory:

   ```sh
   ls /etc/config
   ```

   You should see the `config.properties` and `logging.properties` files.

2. **View the contents of the mounted files:**

   View the contents of the `config.properties` file:

   ```sh
   cat /etc/config/config.properties
   ```

   You should see:

   ```
   app.name=MyApp
   app.version=1.0.0
   ```

   View the contents of the `logging.properties` file:

   ```sh
   cat /etc/config/logging.properties
   ```

   You should see:

   ```
   log.level=INFO
   log.output=stdout
   ```

### Step 4: Clean Up

After verifying that the application reads the configuration data correctly, you can clean up the resources:

```bash
kubectl delete pod configmap-pod
kubectl delete configmap app-config
```

### Official Kubernetes Resources

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [ConfigMap as a Volume](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#add-configmap-data-to-a-volume)


**Create a Secret for a database password and consume it in a pod through environment variables. Verify that the application accesses the secret data correctly.**

### Step 1: Create the Secret

First, create a Secret that stores the database password. Save the following YAML as `db-secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_PASSWORD: cGFzc3dvcmQ=  # Base64 encoded value of 'password'
```

Apply the Secret:

```bash
kubectl apply -f db-secret.yaml
```

To encode the password using base64, you can use the following command:

```bash
echo -n 'password' | base64
```

### Step 2: Create a Pod that Consumes the Secret via Environment Variables

Next, create a pod that uses the Secret as an environment variable. Save the following YAML as `app-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ["sh", "-c", "echo DB_PASSWORD is $DB_PASSWORD; sleep 3600"]
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASSWORD
```

Apply the pod:

```bash
kubectl apply -f app-pod.yaml
```

### Step 3: Verify the Application Accesses the Secret Data Correctly

1. **Check the logs of the pod to verify that the secret was accessed correctly:**

   Use the following command to check the logs of the running pod:

   ```bash
   kubectl logs secret-env-pod
   ```

   You should see output similar to:

   ```
   DB_PASSWORD is password
   ```

   This confirms that the application accessed the secret data correctly through the environment variable.

2. **Alternatively, you can exec into the pod and echo the environment variable:**

   Exec into the running pod:

   ```bash
   kubectl exec -it secret-env-pod -- sh
   ```

   Inside the pod, check the environment variable:

   ```sh
   echo $DB_PASSWORD
   ```

   It should output:

   ```
   password
   ```

### Step 4: Clean Up

After verification, clean up the resources:

```bash
kubectl delete pod secret-env-pod
kubectl delete secret db-secret
```

### Official Kubernetes Resources

- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Secrets as Environment Variables](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables)


**Configure a pod to use a custom ServiceAccount with limited permissions. Test the permissions by attempting to perform unauthorized actions from within the pod.**

### Step 1: Create a Custom ServiceAccount

First, create a custom ServiceAccount that the pod will use. Save the following YAML as `custom-sa.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: custom-sa
  namespace: default
```

Apply the ServiceAccount:

```bash
kubectl apply -f custom-sa.yaml
```

### Step 2: Create a Role with Limited Permissions

Create a Role that grants limited permissions. For this example, the Role will only allow reading Pods. Save the following YAML as `limited-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: limited-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Apply the Role:

```bash
kubectl apply -f limited-role.yaml
```

### Step 3: Bind the Role to the ServiceAccount

Bind the Role to the ServiceAccount using a RoleBinding. Save the following YAML as `rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: limited-rolebinding
  namespace: default
subjects:
- kind: ServiceAccount
  name: custom-sa
  namespace: default
roleRef:
  kind: Role
  name: limited-role
  apiGroup: rbac.authorization.k8s.io
```

Apply the RoleBinding:

```bash
kubectl apply -f rolebinding.yaml
```

### Step 4: Create a Pod that Uses the Custom ServiceAccount

Next, create a pod that uses the custom ServiceAccount. Save the following YAML as `sa-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-pod
spec:
  serviceAccountName: custom-sa
  containers:
  - name: sa-container
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
```

Apply the pod:

```bash
kubectl apply -f sa-pod.yaml
```

### Step 5: Test the Permissions from Within the Pod

1. **Exec into the Pod:**

   Exec into the running pod:

   ```bash
   kubectl exec -it sa-pod -- sh
   ```

2. **Test the Authorized Actions:**

   Attempt to list the pods (this should succeed since the Role allows `get` and `list` actions on Pods):

   ```sh
   kubectl get pods
   ```

   You should see a list of pods in the `default` namespace.

3. **Test the Unauthorized Actions:**

   Attempt to create a pod (this should fail since the Role does not allow `create` actions):

   ```sh
   kubectl run test-pod --image=nginx
   ```

   The command should fail with a permission error, indicating that the ServiceAccount does not have the required permissions.

### Step 6: Clean Up

After testing, clean up the resources:

```bash
kubectl delete pod sa-pod
kubectl delete rolebinding limited-rolebinding
kubectl delete role limited-role
kubectl delete serviceaccount custom-sa
```

### Official Kubernetes Resources

- [ServiceAccounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Roles and RoleBindings](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-rolebinding)

**Set up and test ResourceQuotas and LimitRanges in a namespace to control the amount of resources used by different pods.**

### Step 1: Create a Namespace for Testing

First, create a dedicated namespace where you will apply the `ResourceQuota` and `LimitRange` configurations. Save the following YAML as `test-namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: resource-limits-test
```

Apply the namespace:

```bash
kubectl apply -f test-namespace.yaml
```

### Step 2: Set Up a ResourceQuota

A `ResourceQuota` limits the total amount of resources that can be consumed by all the pods in a namespace. Save the following YAML as `resource-quota.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-resources
  namespace: resource-limits-test
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: "8Gi"
    limits.cpu: "8"
    limits.memory: "16Gi"
```

Apply the `ResourceQuota`:

```bash
kubectl apply -f resource-quota.yaml
```

### Step 3: Set Up a LimitRange

A `LimitRange` sets default resource requests and limits for individual pods or containers in a namespace. Save the following YAML as `limit-range.yaml`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limit-range
  namespace: resource-limits-test
spec:
  limits:
  - max:
      cpu: "2"
      memory: "2Gi"
    min:
      cpu: "200m"
      memory: "256Mi"
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "300m"
      memory: "256Mi"
    type: Container
```

Apply the `LimitRange`:

```bash
kubectl apply -f limit-range.yaml
```

### Step 4: Test the ResourceQuotas and LimitRanges

1. **Create a Pod within the Namespace:**

   Create a pod to see how the `LimitRange` applies. Save the following YAML as `test-pod.yaml`:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: test-pod
     namespace: resource-limits-test
   spec:
     containers:
     - name: test-container
       image: nginx
   ```

   Apply the pod:

   ```bash
   kubectl apply -f test-pod.yaml
   ```

   After creating the pod, you can describe it to see the applied resource limits and requests:

   ```bash
   kubectl describe pod test-pod -n resource-limits-test
   ```

   You should see that the pod's container has been assigned the default resource requests and limits defined in the `LimitRange`.

2. **Attempt to Create a Pod that Exceeds the Limits:**

   Now, try to create a pod that requests more resources than allowed by the `LimitRange`. Save the following YAML as `exceed-limits-pod.yaml`:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: exceed-limits-pod
     namespace: resource-limits-test
   spec:
     containers:
     - name: test-container
       image: nginx
       resources:
         requests:
           cpu: "3"
           memory: "4Gi"
         limits:
           cpu: "3"
           memory: "4Gi"
   ```

   Apply the pod:

   ```bash
   kubectl apply -f exceed-limits-pod.yaml
   ```

   This pod should not be scheduled, and you can check the events to see the failure reason:

   ```bash
   kubectl describe pod exceed-limits-pod -n resource-limits-test
   ```

   The output should indicate that the requested resources exceed the limits defined by the `LimitRange`.

3. **Test the ResourceQuota by Exceeding Namespace Limits:**

   Create multiple pods to exceed the total resource limits defined in the `ResourceQuota`. Here's an example YAML for a pod with higher resource requests, which you can replicate multiple times:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: quota-test-pod
     namespace: resource-limits-test
   spec:
     containers:
     - name: quota-test-container
       image: nginx
       resources:
         requests:
           cpu: "1"
           memory: "1Gi"
         limits:
           cpu: "1"
           memory: "1Gi"
   ```

   Apply this pod multiple times until the namespace exceeds the `ResourceQuota` limits:

   ```bash
   kubectl apply -f quota-test-pod.yaml
   ```

   Once the limit is exceeded, attempts to create more pods will fail with a message indicating that the resource quota has been exceeded.

### Step 5: Clean Up

After testing, clean up the resources:

```bash
kubectl delete namespace resource-limits-test
```

### Official Kubernetes Resources

- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)


**Deploy a web application that requires TLS and configure it to use a Secret containing a TLS certificate. Verify that the application is accessible via HTTPS.**

### Step 1: Create the TLS Secret

First, you need to have a TLS certificate and key. If you don’t have one, you can create a self-signed certificate for testing purposes:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=mywebapp/O=mywebapp"
```

This command generates `tls.crt` and `tls.key` files.

Next, create a Kubernetes Secret to store the TLS certificate and key. Save the following YAML as `tls-secret.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-tls.crt>
  tls.key: <base64-encoded-tls.key>
```

Alternatively, you can create the secret directly using the command line:

```bash
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
```

### Step 2: Deploy a Web Application Configured for TLS

Next, deploy a simple web application (e.g., Nginx) that is configured to use the TLS Secret. Save the following YAML as `web-app-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 443
        volumeMounts:
        - name: tls-secret
          mountPath: /etc/nginx/ssl
          readOnly: true
      volumes:
      - name: tls-secret
        secret:
          secretName: tls-secret
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 443
    targetPort: 443
  type: LoadBalancer
```

This configuration mounts the TLS Secret into the `/etc/nginx/ssl` directory in the Nginx container.

### Step 3: Configure Nginx to Use the TLS Certificate

You need to modify the Nginx configuration to use the TLS certificate and key. You can do this by adding a custom Nginx configuration file.

Create a ConfigMap that contains the custom Nginx configuration. Save the following YAML as `nginx-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events {}
    http {
        server {
            listen 443 ssl;
            server_name mywebapp;

            ssl_certificate /etc/nginx/ssl/tls.crt;
            ssl_certificate_key /etc/nginx/ssl/tls.key;

            location / {
                root   /usr/share/nginx/html;
                index  index.html index.htm;
            }
        }
    }
```

Update the Deployment to use this ConfigMap. Save the updated `web-app-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 443
        volumeMounts:
        - name: tls-secret
          mountPath: /etc/nginx/ssl
          readOnly: true
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
          readOnly: true
      volumes:
      - name: tls-secret
        secret:
          secretName: tls-secret
      - name: nginx-config
        configMap:
          name: nginx-config
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 443
    targetPort: 443
  type: LoadBalancer
```

Apply the ConfigMap and the Deployment:

```bash
kubectl apply -f nginx-configmap.yaml
kubectl apply -f web-app-deployment.yaml
```

### Step 4: Verify the Application is Accessible via HTTPS

1. **Get the External IP:**

   Get the external IP of the service:

   ```bash
   kubectl get svc web-app-service
   ```

   Note the `EXTERNAL-IP`.

2. **Access the Application:**

   Open a web browser and navigate to `https://<EXTERNAL-IP>`. You should see the default Nginx welcome page, which indicates that the application is successfully serving traffic over HTTPS.

3. **Verify the TLS Certificate:**

   Use `curl` to verify that the TLS certificate is being used:

   ```bash
   curl -k https://<EXTERNAL-IP>
   ```

   The `-k` option is used to bypass certificate validation for self-signed certificates.

### Step 5: Clean Up

After testing, clean up the resources:

```bash
kubectl delete deployment web-app
kubectl delete service web-app-service
kubectl delete secret tls-secret
kubectl delete configmap nginx-config
```

### Official Kubernetes Resources

- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [TLS for NGINX](https://docs.nginx.com/nginx/admin-guide/security-controls/terminating-ssl-http/)


**Use admission controllers to enforce policies that prevent pods from running as the root user. Deploy a test pod to validate the policy enforcement.**

### Step 1: Enable the Admission Controller

Kubernetes uses admission controllers to enforce policies at the time of resource creation. The `PodSecurity` admission controller is commonly used to enforce policies like preventing pods from running as the root user. 

**Note:** As of Kubernetes 1.23, the PodSecurityPolicy (PSP) admission controller is deprecated and replaced by the Pod Security Standards (PSS) using the `PodSecurity` admission controller. Below are steps based on the new Pod Security Standards approach.

### Step 2: Create a Namespace with a Pod Security Level

To enforce a policy that prevents pods from running as the root user, you can create a namespace with the `restricted` Pod Security Standard, which does not allow root privileges. Save the following YAML as `restricted-namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: restricted-ns
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

Apply the namespace:

```bash
kubectl apply -f restricted-namespace.yaml
```

### Step 3: Deploy a Test Pod that Attempts to Run as Root

Create a test pod that attempts to run as the root user to validate that the policy enforcement is working. Save the following YAML as `test-root-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: root-test-pod
  namespace: restricted-ns
spec:
  containers:
  - name: test-container
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      runAsUser: 0
```

Apply the test pod:

```bash
kubectl apply -f test-root-pod.yaml
```

### Step 4: Validate the Policy Enforcement

1. **Check the Status of the Pod:**

   The pod should not be created due to the enforced policy. Check the pod's status:

   ```bash
   kubectl get pods -n restricted-ns
   ```

   The pod should either not appear, or if it does appear, it should be in a `Failed` or `Pending` state.

2. **Describe the Pod to See the Rejection Reason:**

   Describe the pod to see why it was rejected:

   ```bash
   kubectl describe pod root-test-pod -n restricted-ns
   ```

   In the description, you should see an event or message explaining that the pod was rejected due to attempting to run as root, which violates the namespace's `restricted` Pod Security Standard.

### Step 5: Deploy a Valid Pod

To further confirm the policy enforcement, deploy a pod that adheres to the `restricted` security context by running as a non-root user. Save the following YAML as `test-nonroot-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nonroot-test-pod
  namespace: restricted-ns
spec:
  containers:
  - name: test-container
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    securityContext:
      runAsUser: 1000
```

Apply the valid pod:

```bash
kubectl apply -f test-nonroot-pod.yaml
```

Check the status of the pod:

```bash
kubectl get pods -n restricted-ns
```

The pod should be in the `Running` state, confirming that it adheres to the security policy.

### Step 6: Clean Up

After testing, clean up the resources:

```bash
kubectl delete pod root-test-pod nonroot-test-pod -n restricted-ns
kubectl delete namespace restricted-ns
```

### Official Kubernetes Resources

- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)


**Implement PodSecurityPolicies to restrict pod creation to only those that meet security criteria. Test the policy by attempting to deploy various pod configurations.**

As of Kubernetes 1.21, **PodSecurityPolicies (PSP)** have been deprecated and are replaced by **Pod Security Admission** in Kubernetes 1.23 and beyond. However, if you're still working with a Kubernetes version that supports PSP, here’s how you would implement them. I'll also include how you would accomplish similar controls using the new Pod Security Admission for environments where PSP is no longer available.

### Step 1: Enable PodSecurityPolicies (if applicable)

Ensure that the PodSecurityPolicy admission controller is enabled in your Kubernetes cluster. This typically requires cluster admin access to modify the API server configuration, which might be beyond typical user permissions in a managed Kubernetes environment. Once PSP is enabled, you can define and apply PodSecurityPolicies.

### Step 2: Create a PodSecurityPolicy

Create a PSP that enforces specific security criteria, such as preventing privileged containers and requiring that pods run as a non-root user. Save the following YAML as `restricted-psp.yaml`:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - 'configMap'
  - 'emptyDir'
  - 'projected'
  - 'secret'
  - 'downwardAPI'
  - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  readOnlyRootFilesystem: false
```

Apply the PSP:

```bash
kubectl apply -f restricted-psp.yaml
```

### Step 3: Create a Role and RoleBinding

Next, you need to bind the PSP to specific users or service accounts. Create a Role and RoleBinding that allows the use of the `restricted-psp`. Save the following YAML as `psp-rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: use-psp
  namespace: default
rules:
- apiGroups:
  - policy
  resources:
  - podsecuritypolicies
  verbs:
  - use
  resourceNames:
  - restricted-psp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-psp
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: use-psp
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
```

Apply the Role and RoleBinding:

```bash
kubectl apply -f psp-rolebinding.yaml
```

### Step 4: Test the Policy with Various Pod Configurations

1. **Test a Compliant Pod:**

   Create a pod that adheres to the PSP’s restrictions. Save the following YAML as `compliant-pod.yaml`:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: compliant-pod
   spec:
     containers:
     - name: nginx
       image: nginx
       securityContext:
         runAsUser: 1000
         allowPrivilegeEscalation: false
   ```

   Apply the pod:

   ```bash
   kubectl apply -f compliant-pod.yaml
   ```

   This pod should be created successfully.

2. **Test a Non-Compliant Pod:**

   Now, create a pod that violates the PSP (e.g., a pod that tries to run as root). Save the following YAML as `noncompliant-pod.yaml`:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: noncompliant-pod
   spec:
     containers:
     - name: nginx
       image: nginx
       securityContext:
         runAsUser: 0
         allowPrivilegeEscalation: true
   ```

   Apply the pod:

   ```bash
   kubectl apply -f noncompliant-pod.yaml
   ```

   The creation of this pod should be denied due to the PodSecurityPolicy.

3. **Check Pod Status:**

   You can verify the pod statuses with:

   ```bash
   kubectl get pods
   ```

   The non-compliant pod should either not appear or should show as `Failed` or `Pending`.

   Describe the non-compliant pod to see why it failed:

   ```bash
   kubectl describe pod noncompliant-pod
   ```

   The output should include a message indicating that the pod was rejected due to policy violations.

### Step 5: Clean Up

After testing, clean up the resources:

```bash
kubectl delete pod compliant-pod noncompliant-pod
kubectl delete rolebinding bind-psp
kubectl delete role use-psp
kubectl delete podsecuritypolicy restricted-psp
```

### Step 6: Implement Similar Controls with Pod Security Admission (for Kubernetes 1.23 and later)

For clusters running Kubernetes 1.23 or later, replace PSP with Pod Security Admission. You would enforce the equivalent restrictions by setting the `enforce` label on namespaces to `restricted`. Here’s an example:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: secure-ns
  labels:
    pod-security.kubernetes.io/enforce: restricted
```

This automatically applies the "restricted" security profile to all pods in the namespace, preventing actions like running as root or using privileged containers.

### Official Kubernetes Resources

- [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
- [PodSecurityPolicy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) (Deprecated)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

