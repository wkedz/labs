---
id: 2024-09-17-08:23-application_observability_and_maintenance
aliases: []
tags:
  - k8s
  - ckad
date: "2024-09-17"
title: application_observability_and_maintenance
---

# application_observability_and_maintenance

**Deploy a pod with readiness, liveness, and startup probes configured. Modify the probes to simulate a failure and observe how Kubernetes handles the failed health checks. Adjust the probe configurations to make the application stable again.**

### Step 1: Deploy a Pod with Readiness, Liveness, and Startup Probes

First, create a pod that uses all three types of probes. We will use an Nginx container for this example. Save the following YAML as `probes-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probes-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 10
    startupProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 0
      periodSeconds: 10
      failureThreshold: 30
```

Apply the pod:

```bash
kubectl apply -f probes-pod.yaml
```

### Step 2: Monitor the Pod’s Health

Watch the pod's status to observe how Kubernetes handles the pod with the configured probes:

```bash
kubectl get pod probes-pod --watch
```

The pod should start normally, and you can use the following command to see details about the probes:

```bash
kubectl describe pod probes-pod
```

### Step 3: Simulate a Probe Failure

To simulate a failure, modify the liveness probe to fail by pointing it to an incorrect path. Save the following YAML as `probes-pod-fail.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probes-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /wrongpath
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 10
    startupProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 0
      periodSeconds: 10
      failureThreshold: 30
```

Apply the updated pod configuration:

```bash
kubectl apply -f probes-pod-fail.yaml
```

### Step 4: Observe Kubernetes Handling of Failed Health Checks

After applying the failing liveness probe, Kubernetes should detect that the liveness probe is failing and eventually restart the pod.

Monitor the pod:

```bash
kubectl get pod probes-pod --watch
```

You should see the pod enter a `CrashLoopBackOff` state as Kubernetes repeatedly restarts the pod due to failed liveness checks.

Check the events and logs for more details:

```bash
kubectl describe pod probes-pod
kubectl logs probes-pod
```

### Step 5: Fix the Probes to Stabilize the Application

Now, correct the liveness probe path to stabilize the application. Save the following YAML as `probes-pod-fixed.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probes-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 10
    startupProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 0
      periodSeconds: 10
      failureThreshold: 30
```

Apply the fixed pod configuration:

```bash
kubectl apply -f probes-pod-fixed.yaml
```

### Step 6: Verify the Pod’s Stability

Monitor the pod to ensure it stabilizes and runs normally:

```bash
kubectl get pod probes-pod --watch
```

The pod should now run without issues, with all probes passing successfully.

### Step 7: Clean Up

After testing, clean up the resources:

```bash
kubectl delete pod probes-pod
```

### Official Kubernetes Resources

- [Liveness, Readiness, and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Kubernetes Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)


**Use kubectl to monitor the CPU and memory usage of all pods in a namespace. Identify the pod with the highest resource consumption and describe steps to optimize its resource usage.**

### Step 1: Monitor CPU and Memory Usage of All Pods in a Namespace

You can monitor the CPU and memory usage of all pods in a namespace using the `kubectl top` command. This command requires the Metrics Server to be installed in your cluster.

```bash
kubectl top pod -n <namespace>
```

Replace `<namespace>` with the actual namespace you want to monitor. For example, if you're monitoring the `default` namespace:

```bash
kubectl top pod -n default
```

This command will output something like:

```
NAME             CPU(cores)   MEMORY(bytes)
pod-1            50m          128Mi
pod-2            200m         512Mi
pod-3            300m         1Gi
```

### Step 2: Identify the Pod with the Highest Resource Consumption

Look at the output from the `kubectl top pod` command and identify the pod with the highest CPU and memory usage. Suppose `pod-3` has the highest CPU and memory consumption:

```
NAME             CPU(cores)   MEMORY(bytes)
pod-3            300m         1Gi
```

### Step 3: Describe Steps to Optimize Resource Usage

Here are some steps you can take to optimize the resource usage of the identified pod:

1. **Review Resource Requests and Limits:**

   Check if the pod has appropriate resource requests and limits set. If the pod has no limits, it may consume more resources than necessary.

   ```bash
   kubectl describe pod pod-3 -n <namespace>
   ```

   Look for the `requests` and `limits` fields under each container’s `resources` section. If the requests are set too high, the pod may be allocated more resources than needed. Conversely, if they are too low, the pod may experience resource contention.

2. **Right-Size the Resource Requests and Limits:**

   Based on the observed usage, adjust the pod's resource requests and limits in its deployment or pod specification:

   ```yaml
   resources:
     requests:
       cpu: "200m"
       memory: "512Mi"
     limits:
       cpu: "300m"
       memory: "1Gi"
   ```

   Apply the changes to the deployment or pod definition:

   ```bash
   kubectl apply -f your-deployment.yaml
   ```

3. **Optimize the Application:**

   - **Code Optimization:** Review the application code running in the pod. Look for inefficient algorithms, excessive logging, or other resource-intensive operations that can be optimized.
   - **Concurrency Management:** Ensure that the application properly handles concurrency. Too many concurrent threads or processes can spike CPU usage.
   - **Memory Management:** Ensure there are no memory leaks. Use tools like profilers or memory analyzers to detect memory inefficiencies.

4. **Horizontal Pod Autoscaling (HPA):**

   If the pod consistently consumes high resources but needs to scale based on load, consider using Horizontal Pod Autoscaling (HPA) to automatically adjust the number of pod replicas based on CPU or memory usage:

   ```bash
   kubectl autoscale deployment <deployment-name> --cpu-percent=50 --min=1 --max=10
   ```

   This command sets up autoscaling for the deployment based on CPU usage.

5. **Use More Efficient Libraries or Frameworks:**

   If the application relies on external libraries or frameworks, check if there are more efficient alternatives that could reduce resource consumption.

6. **Limit Unnecessary Processes:**

   Ensure the pod isn't running any unnecessary background processes or services that could be consuming extra resources.

### Step 4: Monitor the Pod After Optimization

After making the changes, monitor the pod again using the `kubectl top pod` command to see if the optimizations have reduced the resource consumption:

```bash
kubectl top pod -n <namespace>
```

Compare the new resource usage with the previous values to assess the impact of your optimizations.

### Official Kubernetes Resources

- [kubectl top](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#monitoring)
- [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)


**Debug a pod stuck in CrashLoopBackOff. Examine the pod's logs and events, identify the root cause of the crash, and apply a fix to get the pod running normally.**

### Step 1: Identify the Pod in CrashLoopBackOff State

First, identify the pod that is stuck in the `CrashLoopBackOff` state. You can do this by listing all the pods in the namespace:

```bash
kubectl get pods -n <namespace>
```

Look for the pod that shows the `CrashLoopBackOff` status. For example:

```
NAME              READY   STATUS             RESTARTS   AGE
my-app-pod        0/1     CrashLoopBackOff   5          10m
```

### Step 2: Describe the Pod to Get More Details

Next, use the `kubectl describe` command to get more information about the pod’s state, including recent events and the reason for the crash:

```bash
kubectl describe pod my-app-pod -n <namespace>
```

In the output, look for:

- **Events:** Check the "Events" section at the bottom for any warnings or errors that might indicate why the pod is crashing.
- **State:** Check the `State` of the container(s) to see if there are any clues (e.g., OOMKilled, Error, etc.).

### Step 3: Check the Pod Logs

To understand why the pod is crashing, check the logs of the pod:

```bash
kubectl logs my-app-pod -n <namespace>
```

If the pod has multiple containers, specify the container name:

```bash
kubectl logs my-app-pod -c <container-name> -n <namespace>
```

Look for any error messages or stack traces in the logs that indicate why the application is failing.

### Step 4: Common Issues and Fixes

Based on the logs and events, here are some common issues and how to fix them:

1. **Application Errors:**
   - **Issue:** The application might be failing due to a bug, misconfiguration, or missing dependencies.
   - **Fix:** Based on the error in the logs, you might need to fix the application code, correct environment variables, or update the pod's configuration (e.g., ConfigMaps or Secrets).

2. **Insufficient Resources:**
   - **Issue:** The pod may be running out of CPU or memory, leading to OOMKilled (Out of Memory) errors.
   - **Fix:** Increase the resource requests and limits in the pod’s configuration.
     ```yaml
     resources:
       requests:
         memory: "512Mi"
         cpu: "250m"
       limits:
         memory: "1Gi"
         cpu: "500m"
     ```

3. **Crash Due to Misconfiguration:**
   - **Issue:** The pod might be crashing due to an incorrect configuration, such as a wrong command, incorrect arguments, or missing environment variables.
   - **Fix:** Correct the configuration in the deployment or pod specification.
     ```yaml
     command: ["sh", "-c", "corrected_command_here"]
     ```

4. **Failed Liveness or Startup Probes:**
   - **Issue:** The pod might be getting killed due to failing liveness or startup probes.
   - **Fix:** Adjust the probe configuration or disable it temporarily to see if the pod stabilizes.
     ```yaml
     livenessProbe:
       httpGet:
         path: /healthz
         port: 8080
       initialDelaySeconds: 30
       periodSeconds: 10
     ```

5. **Dependency Issues:**
   - **Issue:** The application might be depending on a service that is not available (e.g., a database, external API).
   - **Fix:** Ensure that all dependencies are available and correctly configured.

### Step 5: Apply the Fix

After identifying the root cause, update the deployment, StatefulSet, or pod definition to fix the issue. For example, if the problem was due to insufficient memory, you would update the resource requests and limits:

```bash
kubectl edit deployment my-app-deployment -n <namespace>
```

After editing the resource, Kubernetes will automatically apply the changes and attempt to restart the pod.

### Step 6: Monitor the Pod After Applying the Fix

Once the fix is applied, monitor the pod to ensure it starts normally:

```bash
kubectl get pods -n <namespace> --watch
```

The pod should transition from `Pending` to `Running` without entering the `CrashLoopBackOff` state.

### Step 7: Clean Up (if necessary)

If you made temporary changes for debugging (e.g., disabling probes), ensure to revert those changes once the root cause is fixed.

### Official Kubernetes Resources

- [Debugging Kubernetes Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)


**Configure a deployment with application logs directed to a sidecar container running Fluentd. Verify that logs are correctly collected and output to a specified location.**

### Step 1: Create a Deployment with a Sidecar for Logging

To set up a deployment with an application container and a Fluentd sidecar container, follow these steps. The Fluentd container will collect logs from the application container and output them to a specified location.

Save the following YAML as `fluentd-sidecar-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-logging
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
        image: busybox
        command: ["sh", "-c", "while true; do echo $(date) Hello from myapp-container; sleep 5; done"]
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/myapp
      - name: fluentd-sidecar
        image: fluent/fluentd:latest
        env:
        - name: FLUENTD_CONF
          value: "fluentd.conf"
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/myapp
        - name: fluentd-config
          mountPath: /fluentd/etc/
      volumes:
      - name: log-volume
        emptyDir: {}
      - name: fluentd-config
        configMap:
          name: fluentd-config
```

### Step 2: Create a ConfigMap for Fluentd Configuration

You need to configure Fluentd to collect logs from the application container. Create a ConfigMap that contains the Fluentd configuration. Save the following YAML as `fluentd-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluentd.conf: |
    <source>
      @type tail
      path /var/log/myapp/*.log
      pos_file /var/log/myapp/fluentd.pos
      tag myapp.logs
      <parse>
        @type none
      </parse>
    </source>

    <match **>
      @type stdout
    </match>
```

In this configuration:
- Fluentd tails all log files in `/var/log/myapp/`.
- The logs are tagged as `myapp.logs`.
- The logs are output to stdout for simplicity, but you can modify the `<match>` section to direct logs to other destinations, such as a file, Elasticsearch, or a remote logging service.

Apply the ConfigMap:

```bash
kubectl apply -f fluentd-configmap.yaml
```

### Step 3: Deploy the Application with Fluentd Sidecar

Apply the deployment with the sidecar container:

```bash
kubectl apply -f fluentd-sidecar-deployment.yaml
```

### Step 4: Verify that Logs are Collected by Fluentd

1. **Check the Status of the Pods:**

   Ensure that the pods are running:

   ```bash
   kubectl get pods
   ```

2. **Inspect the Logs from the Fluentd Sidecar Container:**

   To verify that Fluentd is collecting logs, check the logs of the Fluentd container:

   ```bash
   kubectl logs <pod-name> -c fluentd-sidecar
   ```

   Replace `<pod-name>` with the name of the running pod (you can get this from the `kubectl get pods` command).

   You should see the application logs output by Fluentd, such as:

   ```
   2024-09-24 12:34:56 +0000 [info]: #0 [myapp.logs] 2024-09-24 12:34:56 Hello from myapp-container
   2024-09-24 12:35:01 +0000 [info]: #0 [myapp.logs] 2024-09-24 12:35:01 Hello from myapp-container
   ```

   This indicates that the logs from the `myapp-container` are being successfully collected by Fluentd.

### Step 5: Customize Fluentd Output (Optional)

If you want to direct logs to a file or an external logging service, modify the `<match>` section in the `fluentd.conf` configuration file within the ConfigMap. For example, to write logs to a file:

```yaml
<match **>
  @type file
  path /fluentd/log/myapp.log
</match>
```

Make sure to mount a volume to store the logs if you choose to output them to a file.

### Step 6: Clean Up

After testing, you can clean up the resources:

```bash
kubectl delete deployment app-with-logging
kubectl delete configmap fluentd-config
```

### Official Kubernetes Resources

- [Fluentd Documentation](https://docs.fluentd.org/)
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Logging in Kubernetes](https://kubernetes.io/docs/concepts/cluster-administration/logging/)


**Configure a liveness probe that restarts a container if it becomes unresponsive. Simulate a failure and observe Kubernetes restarting the container automatically.**

### Step 1: Create a Pod with a Liveness Probe

To configure a liveness probe that will restart a container if it becomes unresponsive, you can use an example application like `busybox`. This application will simulate a failure by sleeping indefinitely, which will cause the liveness probe to fail.

Save the following YAML as `liveness-probe-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-demo
spec:
  containers:
  - name: liveness-demo-container
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      touch /tmp/healthy;
      sleep 30;
      rm -rf /tmp/healthy;
      sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

### Explanation of the YAML
- **Container:** The `busybox` container starts by creating a file `/tmp/healthy`. It then sleeps for 30 seconds, after which it deletes the `/tmp/healthy` file and sleeps for 600 seconds.
- **Liveness Probe:** The liveness probe checks for the presence of the `/tmp/healthy` file every 5 seconds. If the file is not found, the probe fails, and Kubernetes will restart the container.
- **Initial Delay:** The liveness probe starts 5 seconds after the container starts.

### Step 2: Deploy the Pod

Apply the YAML to create the pod:

```bash
kubectl apply -f liveness-probe-pod.yaml
```

### Step 3: Observe the Liveness Probe in Action

1. **Monitor the Pod:**

   Use the following command to monitor the pod's status:

   ```bash
   kubectl get pod liveness-demo --watch
   ```

   Initially, the pod should be in the `Running` state. After 30 seconds, the liveness probe will fail because the `/tmp/healthy` file is deleted, and Kubernetes will restart the container.

2. **Describe the Pod to Check Liveness Probe Failures:**

   You can get more detailed information about the liveness probe's behavior by describing the pod:

   ```bash
   kubectl describe pod liveness-demo
   ```

   In the "Events" section of the output, you should see events indicating that the liveness probe failed and that the container was restarted:

   ```
   Warning  Unhealthy  1m   kubelet            Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
   Normal   Killing    1m   kubelet            Container liveness-demo-container failed liveness probe, will be restarted
   ```

3. **Check Container Restarts:**

   Verify that the container has been restarted by checking the restart count:

   ```bash
   kubectl get pod liveness-demo
   ```

   The output should show that the `RESTARTS` column has a count greater than 0:

   ```
   NAME             READY   STATUS    RESTARTS   AGE
   liveness-demo    1/1     Running   1          2m
   ```

   This indicates that Kubernetes has successfully restarted the container after the liveness probe failed.

### Step 4: Clean Up

After you have observed the behavior, clean up the resources:

```bash
kubectl delete pod liveness-demo
```

### Official Kubernetes Resources

- [Liveness, Readiness, and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)


**Set up and use the kubectl top command to monitor the resource usage of pods and nodes in your cluster. Identify pods consuming the most resources.**

### Step 1: Ensure Metrics Server is Installed

The `kubectl top` command relies on the Metrics Server to provide resource usage data. If the Metrics Server is not already installed in your cluster, you can install it using the following steps:

1. **Download the Metrics Server manifests:**

   ```bash
   git clone https://github.com/kubernetes-sigs/metrics-server.git
   ```

2. **Navigate to the Metrics Server directory:**

   ```bash
   cd metrics-server
   ```

3. **Deploy the Metrics Server:**

   ```bash
   kubectl apply -f deploy/metrics-server/
   ```

4. **Verify that the Metrics Server is running:**

   ```bash
   kubectl get deployment metrics-server -n kube-system
   ```

   The output should show that the Metrics Server deployment is running.

### Step 2: Use `kubectl top` to Monitor Resource Usage

1. **Monitor Resource Usage of Pods:**

   To view the CPU and memory usage of all pods in a specific namespace:

   ```bash
   kubectl top pod -n <namespace>
   ```

   Replace `<namespace>` with the actual namespace you want to monitor. For example, to monitor the `default` namespace:

   ```bash
   kubectl top pod -n default
   ```

   The output will look like this:

   ```
   NAME             CPU(cores)   MEMORY(bytes)
   pod-1            100m         200Mi
   pod-2            50m          150Mi
   pod-3            250m         500Mi
   ```

   This command lists all pods in the specified namespace along with their current CPU and memory usage.

2. **Monitor Resource Usage of Nodes:**

   To view the CPU and memory usage of nodes in your cluster:

   ```bash
   kubectl top nodes
   ```

   The output will look like this:

   ```
   NAME              CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
   node-1            500m         25%    1024Mi          50%
   node-2            300m         15%    2048Mi          25%
   ```

   This command lists all nodes in the cluster and their current CPU and memory usage.

### Step 3: Identify Pods Consuming the Most Resources

To identify the pods consuming the most resources:

1. **Sort the Output by CPU or Memory Usage:**

   You can use `kubectl top` in combination with `sort` to identify the highest resource-consuming pods. For example, to sort by CPU usage:

   ```bash
   kubectl top pod -n <namespace> --sort-by=cpu
   ```

   Or to sort by memory usage:

   ```bash
   kubectl top pod -n <namespace> --sort-by=memory
   ```

2. **Manually Review the Output:**

   Review the output to see which pods are using the most CPU or memory. For example, if a pod consistently shows high resource usage, it may need further investigation or optimization.

### Example Output for Sorting by Memory Usage

```bash
kubectl top pod -n default --sort-by=memory
```

This command might produce output like:

```
NAME             CPU(cores)   MEMORY(bytes)
pod-3            250m         500Mi
pod-1            100m         200Mi
pod-2            50m          150Mi
```

Here, `pod-3` is consuming the most memory (`500Mi`).

### Step 4: Taking Action on High Resource Usage

If you identify pods that are consuming excessive resources, consider the following actions:

- **Right-Size Resource Requests and Limits:** Adjust the resource requests and limits in the pod’s configuration to better match the actual usage.
- **Scale the Application:** If the resource usage is consistently high due to high load, consider scaling the application by increasing the number of replicas.
- **Optimize the Application:** Investigate the application’s code or configuration to identify inefficiencies or memory leaks that could be causing high resource usage.

### Official Kubernetes Resources

- [Resource Metrics API](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/)
- [kubectl top Command](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#resource-usage)


**Use a combination of kubectl logs, kubectl describe, and kubectl exec to diagnose a failing pod and resolve the issue causing the failure.**

When diagnosing a failing pod in Kubernetes, you can use a combination of `kubectl logs`, `kubectl describe`, and `kubectl exec` to investigate and resolve the issue. Below is a step-by-step guide on how to do this.

### Step 1: Identify the Failing Pod

First, identify the pod that is failing by listing all the pods in the relevant namespace. You can use the following command:

```bash
kubectl get pods -n <namespace>
```

Replace `<namespace>` with the appropriate namespace. Look for pods in states like `CrashLoopBackOff`, `Error`, or `Pending`.

### Step 2: Describe the Pod

Once you've identified the failing pod, use `kubectl describe` to get detailed information about the pod, including events and reasons for failure:

```bash
kubectl describe pod <pod-name> -n <namespace>
```

Replace `<pod-name>` with the name of your failing pod.

- **Events Section:** Look for events at the bottom of the output. These may include messages about failed container start-ups, out-of-memory issues, or scheduling problems.
- **State Section:** In the `State` section under each container, look for reasons like `CrashLoopBackOff`, `Error`, or `OOMKilled`.

### Step 3: Check the Pod Logs

Next, check the logs of the containers within the pod to understand what is happening inside them:

```bash
kubectl logs <pod-name> -n <namespace>
```

If the pod has multiple containers, specify the container name:

```bash
kubectl logs <pod-name> -c <container-name> -n <namespace>
```

- **Error Messages:** Look for any error messages, stack traces, or other logs that indicate why the container is failing.
- **Application-specific Logs:** These might give clues if there are misconfigurations, missing dependencies, or bugs in the application code.

### Step 4: Use kubectl exec to Interact with the Running Container

If the pod is running but behaving unexpectedly (e.g., not crashing but still failing to function correctly), you can use `kubectl exec` to access the container and perform more detailed troubleshooting:

```bash
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
```

Or, if the container has bash:

```bash
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
```

- **Inspect the File System:** Check the configuration files, logs, and other important files inside the container.
- **Check Network Connectivity:** You can use tools like `curl`, `ping`, or `nc` (netcat) to test connectivity to other services that the container depends on.
- **Check Running Processes:** Use `ps`, `top`, or similar commands to inspect the running processes and their resource usage.

### Step 5: Diagnose Common Issues and Apply Fixes

Here are some common issues you might diagnose and potential fixes:

1. **Application Errors (e.g., CrashLoopBackOff):**
   - **Symptom:** Application crashes repeatedly.
   - **Diagnosis:** Logs might show an application error or misconfiguration.
   - **Fix:** Correct the application code, environment variables, or configuration files.

2. **Resource Exhaustion (e.g., OOMKilled):**
   - **Symptom:** Pod is killed due to running out of memory (OutOfMemory).
   - **Diagnosis:** `kubectl describe` might show `OOMKilled`.
   - **Fix:** Increase the memory request/limit in the pod specification or optimize the application to use less memory.

   Example of updating resources:
   ```yaml
   resources:
     requests:
       memory: "512Mi"
       cpu: "250m"
     limits:
       memory: "1Gi"
       cpu: "500m"
   ```

3. **Network Issues:**
   - **Symptom:** Pod cannot connect to required services.
   - **Diagnosis:** Use `kubectl exec` to run network diagnostics like `ping` or `curl`.
   - **Fix:** Ensure the correct network policies, DNS settings, and service configurations are in place.

4. **Image Pull Issues:**
   - **Symptom:** Pod is stuck in `ImagePullBackOff`.
   - **Diagnosis:** `kubectl describe` will show errors related to pulling the container image.
   - **Fix:** Verify the image name, tag, and that the image is available in the specified registry. Also, check for correct imagePullSecrets if pulling from a private registry.

### Step 6: Apply Configuration Fixes and Restart the Pod

After diagnosing the issue and making necessary changes, apply the fixes to your deployment or pod configuration:

```bash
kubectl apply -f <deployment-or-pod-file>.yaml
```

If the pod is part of a deployment, you can scale down and then scale up the deployment to restart the pods:

```bash
kubectl scale deployment <deployment-name> --replicas=0 -n <namespace>
kubectl scale deployment <deployment-name> --replicas=1 -n <namespace>
```

### Step 7: Monitor the Pod After Applying Fixes

After applying the fixes, monitor the pod to ensure that it restarts and runs successfully:

```bash
kubectl get pods -n <namespace> --watch
```

### Official Kubernetes Resources

- [Troubleshooting Applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [kubectl Logs](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs)
- [kubectl Describe](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe)
- [kubectl Exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec)

**Deploy Prometheus in your cluster and configure it to scrape metrics from a sample application. Set up Grafana dashboards to visualize the collected metrics.**

### Step 1: Deploy Prometheus in Your Kubernetes Cluster

First, you need to deploy Prometheus. You can do this using the Prometheus Operator, or by deploying Prometheus directly. Here, we'll go through the steps to deploy Prometheus using a simple setup without the operator.

#### 1.1 Create a Namespace for Monitoring

```bash
kubectl create namespace monitoring
```

#### 1.2 Deploy Prometheus using Helm (Recommended)

If you have Helm installed, you can deploy Prometheus using the official Helm chart:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus -n monitoring
```

This will deploy Prometheus along with some default configurations and service endpoints.

#### 1.3 Alternatively, Deploy Prometheus Manually

If you prefer to deploy Prometheus manually, you can create the necessary resources directly. Save the following YAML files and apply them to your cluster.

- **ConfigMap for Prometheus Configuration**

  Create a file named `prometheus-configmap.yaml`:

  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: prometheus-config
    namespace: monitoring
  data:
    prometheus.yml: |
      global:
        scrape_interval: 15s

      scrape_configs:
        - job_name: 'prometheus'
          static_configs:
            - targets: ['localhost:9090']
  ```

  Apply the ConfigMap:

  ```bash
  kubectl apply -f prometheus-configmap.yaml
  ```

- **Deployment for Prometheus**

  Create a file named `prometheus-deployment.yaml`:

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: prometheus
    namespace: monitoring
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: prometheus
    template:
      metadata:
        labels:
          app: prometheus
      spec:
        containers:
        - name: prometheus
          image: prom/prometheus
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: config-volume
              mountPath: /etc/prometheus/
        volumes:
          - name: config-volume
            configMap:
              name: prometheus-config
  ```

  Apply the Deployment:

  ```bash
  kubectl apply -f prometheus-deployment.yaml
  ```

- **Service for Prometheus**

  Create a file named `prometheus-service.yaml`:

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: prometheus
    namespace: monitoring
  spec:
    type: NodePort
    ports:
      - port: 9090
        targetPort: 9090
        nodePort: 30090
    selector:
      app: prometheus
  ```

  Apply the Service:

  ```bash
  kubectl apply -f prometheus-service.yaml
  ```

### Step 2: Deploy a Sample Application with Metrics Endpoint

To have Prometheus scrape metrics from a sample application, deploy a simple application that exposes metrics.

#### 2.1 Deploy the Sample Application

Create a file named `sample-app-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: prom/prometheus-example-app
        ports:
        - containerPort: 8080
```

Apply the Deployment:

```bash
kubectl apply -f sample-app-deployment.yaml
```

#### 2.2 Expose the Sample Application

Create a Service for the sample application so that Prometheus can scrape metrics from it:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  namespace: monitoring
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: sample-app
```

Apply the Service:

```bash
kubectl apply -f sample-app-service.yaml
```

### Step 3: Configure Prometheus to Scrape the Sample Application

Now, you need to configure Prometheus to scrape metrics from the sample application.

Update the `prometheus-configmap.yaml` to include the sample application in the scrape configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      - job_name: 'sample-app'
        static_configs:
          - targets: ['sample-app-service:8080']
```

Apply the updated ConfigMap:

```bash
kubectl apply -f prometheus-configmap.yaml
```

Restart the Prometheus pod to load the new configuration:

```bash
kubectl delete pod -l app=prometheus -n monitoring
```

### Step 4: Deploy Grafana and Set Up Dashboards

Grafana will allow you to visualize the metrics collected by Prometheus.

#### 4.1 Deploy Grafana Using Helm

If you have Helm installed, you can deploy Grafana using the official Helm chart:

```bash
helm install grafana grafana/grafana -n monitoring
```

Alternatively, you can deploy Grafana manually by creating the necessary Kubernetes resources.

#### 4.2 Access Grafana

Get the Grafana admin password:

```bash
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Forward the Grafana port to your local machine:

```bash
kubectl port-forward service/grafana 3000:3000 -n monitoring
```

Access Grafana at `http://localhost:3000` and log in using `admin` as the username and the password retrieved from the secret.

#### 4.3 Add Prometheus as a Data Source in Grafana

1. Go to **Configuration** -> **Data Sources** -> **Add data source**.
2. Select **Prometheus** as the data source type.
3. In the **HTTP** section, set the URL to `http://prometheus:9090`.
4. Click **Save & Test** to ensure the connection to Prometheus is working.

#### 4.4 Create Dashboards

1. Go to **Create** -> **Dashboard**.
2. Click **Add new panel**.
3. Use the **Query** section to select metrics from Prometheus. For example, you can use a query like `rate(http_requests_total[1m])` to visualize the rate of HTTP requests.
4. Customize the visualization as needed and save the dashboard.

### Step 5: Verify Metrics Collection and Visualization

Once the dashboards are set up, you should see real-time data being visualized in Grafana. Metrics from the sample application should be displayed according to the queries you configured.

### Step 6: Clean Up

If you want to clean up the resources after testing:

```bash
helm uninstall prometheus -n monitoring
helm uninstall grafana -n monitoring
kubectl delete namespace monitoring
```

### Official Kubernetes Resources

- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Kubernetes Monitoring with Prometheus](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/)


**Create a pod with an exec probe that checks the output of a command inside the container. Test different command configurations to see how they affect probe success.**

### Step 1: Create a Pod with an Exec Probe

You can create a pod with an exec probe by defining a `livenessProbe` or `readinessProbe` in the pod's configuration. This probe will execute a command inside the container and consider the pod healthy based on the command's exit code.

Let's create a pod with a basic exec liveness probe. Save the following YAML as `exec-probe-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: exec-probe-pod
spec:
  containers:
  - name: my-container
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      touch /tmp/healthy;
      sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

### Explanation of the YAML

- **Container:** The container runs a `busybox` image, creates a file `/tmp/healthy`, and then sleeps for 600 seconds.
- **Liveness Probe:** The liveness probe executes the command `cat /tmp/healthy` every 5 seconds, starting 5 seconds after the container starts. If the command exits with status code 0, the probe is successful. If the file `/tmp/healthy` is missing, the command fails, and Kubernetes restarts the container.

### Step 2: Deploy the Pod

Apply the pod configuration:

```bash
kubectl apply -f exec-probe-pod.yaml
```

### Step 3: Monitor the Pod's Behavior

Watch the pod's status:

```bash
kubectl get pod exec-probe-pod --watch
```

Initially, the pod should start and run normally because the file `/tmp/healthy` exists. The liveness probe will succeed.

### Step 4: Simulate a Failure by Modifying the Command

Now, simulate a failure by updating the pod configuration to use a different command that will fail. Save the following YAML as `exec-probe-pod-fail.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: exec-probe-pod
spec:
  containers:
  - name: my-container
    image: busybox
    args:
    - /bin/sh
    - -c
    - >
      rm /tmp/healthy;
      sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

Apply the updated configuration:

```bash
kubectl apply -f exec-probe-pod-fail.yaml
```

### Step 5: Observe Kubernetes Handling the Failed Probe

After applying the update, Kubernetes will start the pod and execute the liveness probe. Since the file `/tmp/healthy` is removed immediately, the `cat /tmp/healthy` command will fail, leading to the pod being restarted.

Watch the pod’s status:

```bash
kubectl get pod exec-probe-pod --watch
```

You should see the pod enter a `CrashLoopBackOff` state as Kubernetes continuously tries to restart it due to the failing liveness probe.

### Step 6: Test Different Command Configurations

You can modify the liveness probe to test different command configurations. For example:

- **Successful Command:** Use a command that always succeeds, such as `true`:

  ```yaml
  livenessProbe:
    exec:
      command:
      - true
    initialDelaySeconds: 5
    periodSeconds: 5
  ```

- **Failing Command:** Use a command that always fails, such as `false`:

  ```yaml
  livenessProbe:
    exec:
      command:
      - false
    initialDelaySeconds: 5
    periodSeconds: 5
  ```

- **Custom Command:** Use more complex commands to verify specific conditions inside the container, such as checking if a process is running:

  ```yaml
  livenessProbe:
    exec:
      command:
      - pgrep
      - myprocess
    initialDelaySeconds: 5
    periodSeconds: 5
  ```

Apply these configurations to see how Kubernetes handles the different scenarios.

### Step 7: Clean Up

After testing, clean up the resources:

```bash
kubectl delete pod exec-probe-pod
```

### Official Kubernetes Resources

- [Kubernetes Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Debugging Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

**Configure Fluentd as a sidecar container to collect logs from an application pod and output them to a specified storage backend. Verify the log collection and processing.**

To configure Fluentd as a sidecar container in a Kubernetes pod to collect logs from an application and output them to a specified storage backend, follow these steps:

### Step 1: Set Up the Application Pod with Fluentd Sidecar

We'll start by deploying a simple application with Fluentd as a sidecar container. Fluentd will collect logs from the application container and forward them to a specified backend (e.g., an external log storage service or a file).

#### 1.1 Create the Fluentd Configuration

First, create a ConfigMap that contains the Fluentd configuration. This configuration will define how Fluentd collects logs from the application and where it sends them. Save the following YAML as `fluentd-configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/myapp/*.log
      pos_file /var/log/fluentd.pos
      tag myapp.logs
      <parse>
        @type none
      </parse>
    </source>

    <match **>
      @type stdout
    </match>
```

In this configuration:

- **`@type tail`**: Fluentd is configured to tail logs from files in the `/var/log/myapp/` directory.
- **`@type stdout`**: Fluentd outputs the logs to the standard output. You can modify this section to send logs to a file, Elasticsearch, or any other backend.

Apply the ConfigMap:

```bash
kubectl apply -f fluentd-configmap.yaml
```

#### 1.2 Create the Deployment with Fluentd Sidecar

Next, create a Kubernetes deployment that includes both the application container and the Fluentd sidecar container. Save the following YAML as `app-with-fluentd.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-fluentd
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
        image: busybox
        command: ["sh", "-c", "while true; do echo $(date) Hello from myapp-container >> /var/log/myapp/app.log; sleep 5; done"]
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/myapp
      - name: fluentd-sidecar
        image: fluent/fluentd:latest
        env:
        - name: FLUENTD_CONF
          value: "fluent.conf"
        volumeMounts:
        - name: log-volume
          mountPath: /var/log/myapp
        - name: fluentd-config
          mountPath: /fluentd/etc/
      volumes:
      - name: log-volume
        emptyDir: {}
      - name: fluentd-config
        configMap:
          name: fluentd-config
```

In this deployment:

- The **`myapp-container`** writes logs to `/var/log/myapp/app.log`.
- The **`fluentd-sidecar`** container reads the logs from the same directory and processes them according to the `fluent.conf` configuration.
- The logs are stored in a shared `emptyDir` volume between the containers.

Apply the deployment:

```bash
kubectl apply -f app-with-fluentd.yaml
```

### Step 2: Verify Log Collection and Processing

#### 2.1 Check the Status of the Pods

Ensure the pods are running correctly:

```bash
kubectl get pods
```

#### 2.2 Verify Logs are Being Collected

Check the logs of the Fluentd sidecar container to verify that it is collecting and processing logs from the application container:

```bash
kubectl logs <pod-name> -c fluentd-sidecar
```

Replace `<pod-name>` with the name of the running pod.

You should see log entries similar to:

```
2024-09-24 12:00:00 +0000 [info]: #0 [myapp.logs] 2024-09-24 12:00:00 Hello from myapp-container
2024-09-24 12:00:05 +0000 [info]: #0 [myapp.logs] 2024-09-24 12:00:05 Hello from myapp-container
```

#### 2.3 (Optional) Verify Logs in the Storage Backend

If you configured Fluentd to send logs to an external storage backend (like a file or a service like Elasticsearch), verify that the logs are being received there as expected.

### Step 3: Clean Up

After verifying that Fluentd is collecting and processing logs correctly, you can clean up the resources:

```bash
kubectl delete deployment app-with-fluentd
kubectl delete configmap fluentd-config
```

### Official Resources

- [Fluentd Documentation](https://docs.fluentd.org/)
- [Kubernetes Logging Architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)


**Troubleshoot a scenario where a Deployment fails due to an API deprecation issue. Update the manifest to use the latest API version and re-deploy the application.**

### Step 1: Identify the API Deprecation Issue

When a Deployment fails due to an API deprecation issue, Kubernetes will often provide error messages that indicate the problem. To identify the issue:

1. **Check the Deployment Status:**
   Run the following command to check the status of your deployment:
   ```bash
   kubectl get deployments
   ```

2. **Describe the Deployment:**
   If the Deployment fails, use the `kubectl describe` command to get detailed information, including error messages related to the API version:
   ```bash
   kubectl describe deployment <deployment-name>
   ```

3. **Check Events and Logs:**
   Look for events or logs that indicate an error related to the API version. A common message might be something like:
   ```
   error: unable to recognize "deployment.yaml": no matches for kind "Deployment" in version "extensions/v1beta1"
   ```

### Step 2: Update the Manifest to Use the Latest API Version

If the error indicates that an API version is deprecated, you'll need to update your manifest to use the latest supported API version. For example, the `extensions/v1beta1` API version for Deployments is deprecated and has been removed in recent Kubernetes versions. You should update it to `apps/v1`.

#### 2.1 Example of a Deprecated Manifest

Here is an example of an old manifest using a deprecated API version:

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: nginx
        ports:
        - containerPort: 80
```

#### 2.2 Updated Manifest Using `apps/v1`

Update the `apiVersion` from `extensions/v1beta1` to `apps/v1`, and ensure that the `selector` field is explicitly defined, which is required in the `apps/v1` API version.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-container
        image: nginx
        ports:
        - containerPort: 80
```

### Step 3: Apply the Updated Manifest and Re-deploy the Application

Once you have updated the manifest to use the latest API version, you can apply the changes and re-deploy the application.

1. **Apply the Updated Manifest:**
   ```bash
   kubectl apply -f updated-deployment.yaml
   ```

2. **Verify the Deployment:**
   After applying the updated manifest, check the status of the Deployment to ensure it was successfully created:
   ```bash
   kubectl get deployments
   ```

3. **Check the Pods:**
   Verify that the pods are running:
   ```bash
   kubectl get pods
   ```

### Step 4: Monitor the Application

Finally, monitor the application to ensure it is running as expected. Use the following commands:

- **Check Pod Status:**
  ```bash
  kubectl get pods -o wide
  ```

- **Describe the Pods:**
  ```bash
  kubectl describe pod <pod-name>
  ```

- **Check Logs (if needed):**
  ```bash
  kubectl logs <pod-name>
  ```

### Step 5: Clean Up (Optional)

If this was a test or if you need to revert the changes, you can delete the deployment:

```bash
kubectl delete deployment my-deployment
```

### Official Resources

- [Kubernetes API deprecations and removals](https://kubernetes.io/docs/reference/using-api/deprecation-guide/)
- [Deployments in apps/v1](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)


**Set up tracing for a distributed application using Jaeger. Verify the trace data for requests between different microservices.**

### Setting Up Tracing for a Distributed Application Using Jaeger

To set up tracing for a distributed application using Jaeger and verify the trace data, follow these steps:

### Step 1: Deploy Jaeger in Your Kubernetes Cluster

You can deploy Jaeger in various ways, such as using the Jaeger Operator or directly deploying Jaeger components. Here, we'll use a simplified setup by deploying the Jaeger all-in-one image.

#### 1.1 Deploy Jaeger All-in-One

The Jaeger all-in-one deployment is suitable for development and testing environments. It runs the Jaeger Agent, Collector, Query, and UI in a single pod.

Create a file named `jaeger-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: tracing
  labels:
    app: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:1.33
        ports:
        - containerPort: 5775  # UDP for receiving traces from clients
        - containerPort: 6831  # UDP for receiving traces from clients
        - containerPort: 6832  # UDP for receiving traces from clients
        - containerPort: 5778  # HTTP for configuring the agent
        - containerPort: 16686 # UI and Query API
        - containerPort: 14268 # HTTP for receiving traces from clients
        - containerPort: 14250 # GRPC for receiving traces from clients
        - containerPort: 9411  # HTTP for receiving traces from Zipkin spans
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger
  namespace: tracing
spec:
  ports:
  - port: 5775
    name: udp-sender
    protocol: UDP
  - port: 6831
    name: udp-sender-2
    protocol: UDP
  - port: 6832
    name: udp-sender-3
    protocol: UDP
  - port: 5778
    name: http-config
  - port: 16686
    name: http-query
  - port: 14268
    name: http-collector
  - port: 14250
    name: grpc
  - port: 9411
    name: zipkin
  selector:
    app: jaeger
```

Create the `tracing` namespace and deploy Jaeger:

```bash
kubectl create namespace tracing
kubectl apply -f jaeger-deployment.yaml -n tracing
```

### Step 2: Instrument Your Microservices for Tracing

To collect trace data, your microservices need to be instrumented to send tracing information to Jaeger. Depending on the programming language and framework you're using, you'll need to include the appropriate Jaeger client library.

Here’s a basic example using Python with Flask:

#### 2.1 Install Jaeger Client Library

If you're using Python, install the `jaeger-client` package:

```bash
pip install jaeger-client flask-opentracing
```

#### 2.2 Instrument the Application

Below is an example of a simple Flask application instrumented for tracing:

```python
from flask import Flask, request
from jaeger_client import Config
from flask_opentracing import FlaskTracing

def init_tracer(service_name='my-service'):
    config = Config(
        config={
            'sampler': {'type': 'const', 'param': 1},
            'logging': True,
            'local_agent': {
                'reporting_host': 'jaeger',
                'reporting_port': '6831',
            },
        },
        service_name=service_name,
        validate=True,
    )
    return config.initialize_tracer()

app = Flask(__name__)
tracer = init_tracer()
flask_tracer = FlaskTracing(tracer, True, app)

@app.route('/')
def index():
    with tracer.start_span('index-span') as span:
        span.log_kv({'event': 'index-function', 'value': 'Index endpoint called'})
    return 'Hello from the traced app!'

@app.route('/service')
def service():
    with tracer.start_span('service-span') as span:
        span.log_kv({'event': 'service-function', 'value': 'Service endpoint called'})
    return 'Hello from the service endpoint!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

- **Local Agent:** Ensure that the `reporting_host` points to the Jaeger service (`'jaeger'`) and the `reporting_port` matches the one configured for UDP (usually `6831`).

#### 2.3 Deploy the Instrumented Application

Create a Kubernetes deployment for your instrumented application:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traced-app
  namespace: tracing
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traced-app
  template:
    metadata:
      labels:
        app: traced-app
    spec:
      containers:
      - name: traced-app
        image: your-image-here  # Replace with your Docker image
        ports:
        - containerPort: 5000
```

Deploy the application:

```bash
kubectl apply -f traced-app-deployment.yaml -n tracing
```

### Step 3: Verify the Trace Data

#### 3.1 Access the Jaeger UI

To view the traces, access the Jaeger UI. If you're running Kubernetes locally (e.g., with Minikube), you can forward the port:

```bash
kubectl port-forward service/jaeger 16686:16686 -n tracing
```

Open your browser and go to `http://localhost:16686`.

#### 3.2 Generate Some Traces

Interact with your application (e.g., by sending requests to the `/` and `/service` endpoints):

```bash
curl http://<your-app-service-ip>:5000/
curl http://<your-app-service-ip>:5000/service
```

#### 3.3 View Traces in Jaeger

- In the Jaeger UI, select your service (`my-service`) from the dropdown menu.
- Click "Find Traces" to see the collected traces.
- You should see the trace data corresponding to the requests you made, including details about each span.

### Step 4: Clean Up (Optional)

If you're done testing and want to clean up the resources:

```bash
kubectl delete namespace tracing
```

### Official Resources

- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [OpenTracing Documentation](https://opentracing.io/docs/overview/what-is-tracing/)
- [Flask-OpenTracing Documentation](https://github.com/opentracing-contrib/python-flask)

**Create an alert in Prometheus that triggers when the response time of your application exceeds a threshold. Test the alert by simulating high response times.**

### Step 1: Set Up Prometheus and Your Application

Before setting up the alert, ensure that Prometheus is deployed in your Kubernetes cluster and that your application is instrumented to expose metrics, including response times.

For the sake of this example, let's assume your application exposes a metric called `http_request_duration_seconds`, which tracks the response time of your application.

### Step 2: Create a Prometheus Alerting Rule

Prometheus uses alerting rules to define conditions that should trigger alerts. We will create a rule that triggers an alert when the `http_request_duration_seconds` metric exceeds a specific threshold.

#### 2.1 Create the Alerting Rule

Create a ConfigMap in Kubernetes to store the Prometheus alerting rules. Save the following YAML as `prometheus-alerting-rules.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-alert-rules
  namespace: monitoring
data:
  alert.rules: |
    groups:
    - name: example-alerts
      rules:
      - alert: HighResponseTime
        expr: histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 0.5
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "High response time detected"
          description: "The 99th percentile response time is above 0.5 seconds for the last 5 minutes."
```

Explanation of the alerting rule:

- **`expr`:** This expression uses the `histogram_quantile` function to calculate the 99th percentile response time over the last 5 minutes (`0.99` quantile). If the calculated response time exceeds 0.5 seconds, the alert will trigger.
- **`for`:** The alert will only trigger if the condition holds true for at least 1 minute.
- **`labels`:** The severity is set to `critical`.
- **`annotations`:** Provides additional context for the alert.

Apply the ConfigMap to your cluster:

```bash
kubectl apply -f prometheus-alerting-rules.yaml
```

#### 2.2 Update Prometheus to Use the Alerting Rule

Ensure that your Prometheus instance is configured to use the new alerting rules. If you're using a Helm chart, you might need to update the Prometheus deployment to include the new ConfigMap.

For a manual setup, you can mount the ConfigMap as a volume in your Prometheus deployment and update the Prometheus configuration to include the new rules.

Here's an example of how to reference the ConfigMap in a Prometheus deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  template:
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus/'
          - '--web.console.libraries=/usr/share/prometheus/console_libraries'
          - '--web.console.templates=/usr/share/prometheus/consoles'
          - '--web.enable-lifecycle'
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus/
        - name: rules-volume
          mountPath: /etc/prometheus/rules/
      volumes:
      - name: config-volume
        configMap:
          name: prometheus-config
      - name: rules-volume
        configMap:
          name: prometheus-alert-rules
```

After updating the Prometheus deployment, restart Prometheus to load the new rules.

### Step 3: Set Up Alertmanager (Optional)

Prometheus triggers alerts, but you need Alertmanager to handle notifications (e.g., email, Slack). If you haven’t already set up Alertmanager, you can deploy it using the following steps:

1. **Deploy Alertmanager:**

   ```bash
   helm install alertmanager prometheus-community/alertmanager -n monitoring
   ```

2. **Configure Prometheus to Send Alerts to Alertmanager:**

   Update your Prometheus configuration to include the Alertmanager service:

   ```yaml
   alerting:
     alertmanagers:
       - static_configs:
           - targets:
             - 'alertmanager:9093'
   ```

3. **Create Alertmanager ConfigMap:**

   You can customize Alertmanager to send notifications to various services like email, Slack, etc.

### Step 4: Test the Alert by Simulating High Response Times

#### 4.1 Simulate High Response Times

You can simulate high response times in your application by adding artificial delays. For example, in a Python Flask app:

```python
import time

@app.route('/slow')
def slow():
    time.sleep(1)  # Sleep for 1 second
    return 'This is a slow response!'
```

Deploy this change and make repeated requests to this endpoint:

```bash
while true; do curl http://<your-app-service-ip>:<port>/slow; done
```

This will generate high response times, which should trigger the alert.

#### 4.2 Verify the Alert

1. **Check Prometheus Alerts Page:**

   Access the Prometheus UI and go to the "Alerts" page (`http://<prometheus-ip>:9090/alerts`). You should see the `HighResponseTime` alert in a "Firing" state.

2. **Check Alertmanager (if configured):**

   If you've set up Alertmanager, check that notifications are being sent according to your configuration (e.g., to your email or Slack).

### Step 5: Clean Up

After testing, clean up the resources:

```bash
kubectl delete configmap prometheus-alert-rules -n monitoring
kubectl delete deployment prometheus -n monitoring
```

If you deployed Alertmanager:

```bash
helm uninstall alertmanager -n monitoring
```

### Official Resources

- [Prometheus Alerting](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Prometheus Querying](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)


**Use kubectl port-forward to access a pod’s internal application interface locally. Validate that you can interact with the application as if it were running on your local machine.**

### Step 1: Identify the Pod and Application Port

Before you can use `kubectl port-forward`, you need to know the name of the pod you want to access and the port on which the application inside the pod is listening.

1. **List the pods in your namespace:**

   ```bash
   kubectl get pods -n <namespace>
   ```

   Replace `<namespace>` with the appropriate namespace. If you're using the `default` namespace, you can omit the `-n` flag.

2. **Describe the pod to find the port:**

   If you are not sure which port the application is running on, you can describe the pod:

   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```

   Look for the `Ports` section under the container details, which will show the port(s) the application is using.

### Step 2: Use kubectl port-forward to Access the Pod

Once you have the pod name and the application port, you can use `kubectl port-forward` to access the application locally.

1. **Forward a local port to the pod’s port:**

   ```bash
   kubectl port-forward pod/<pod-name> <local-port>:<pod-port> -n <namespace>
   ```

   Replace the placeholders with the actual values:

   - `<pod-name>`: The name of the pod you want to access.
   - `<local-port>`: The port on your local machine you want to use (e.g., `8080`).
   - `<pod-port>`: The port on which the application inside the pod is listening (e.g., `80`).
   - `<namespace>`: The namespace where the pod is located.

   Example:

   ```bash
   kubectl port-forward pod/my-app-pod 8080:80 -n default
   ```

   This command will forward traffic from `localhost:8080` to `my-app-pod:80` inside the cluster.

### Step 3: Interact with the Application

Now that the port is forwarded, you can interact with the application as if it were running on your local machine.

1. **Access the application using a browser:**

   Open a web browser and navigate to `http://localhost:<local-port>`. For example:

   ```bash
   http://localhost:8080
   ```

2. **Use curl or another HTTP client:**

   You can also use `curl` to interact with the application:

   ```bash
   curl http://localhost:<local-port>
   ```

   Example:

   ```bash
   curl http://localhost:8080
   ```

   This should return the response from the application running inside the pod.

### Step 4: Validate the Interaction

To ensure that the port forwarding is working correctly:

1. **Check the application’s response:**
   - If you receive the expected response from the application, the port-forwarding is working correctly.
   - If the application has a specific endpoint (e.g., `/health` or `/status`), you can access it to validate the application's health.

2. **Monitor the pod logs (optional):**
   - You can monitor the pod’s logs while accessing it to see if requests are being handled correctly:

   ```bash
   kubectl logs <pod-name> -f -n <namespace>
   ```

### Step 5: Stop the Port Forwarding

When you’re done, you can stop the port forwarding by simply pressing `Ctrl+C` in the terminal where `kubectl port-forward` is running.

### Example Scenario

Let’s say you have a pod named `my-app-pod` running in the `default` namespace, and your application is listening on port `80`. You want to access it locally on port `8080`.

You would run:

```bash
kubectl port-forward pod/my-app-pod 8080:80 -n default
```

Now, you can open `http://localhost:8080` in your browser or use `curl http://localhost:8080` to interact with the application.

### Official Kubernetes Resources

- [kubectl port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward)


