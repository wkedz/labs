---
id: 2024-09-17-08:22-application_deployment
aliases: []
tags:
  - k8s
  - ckad
date: "2024-09-17"
links:
  - https://kubernetes.io/blog/2018/04/30/zero-downtime-deployment-kubernetes-jenkins/
title: application_deployment
---

# application_deployment

**Deploy a Kubernetes application using a blue/green deployment strategy. Create two Deployments: blue and green, and switch traffic between them using a Service. Demonstrate how to shift traffic to the green Deployment while minimizing downtime.**

```bash
$ kubectl create deployment blue --image nginx:1.26.1 --port 80 --dry-run=client -o yaml > blue.yaml
$ kubectl apply -f blue.yaml
$ kubectl create deployment green --image nginx:1.26.1 --port 80 --dry-run=client -o yaml > green.yaml
$ kubectl apply -f green.yaml
$ kubectl expose deployment blue --port 8080 --target-port 80
$ kubectl run temp --image=busybox:1.36.1 --restart=Never -it --rm -- wget -O- blue:8080
# In the service configuration change this:
# selector:
#   app: blue
# to
# selector:
#   app: green
$ kubectl edit service blue
$ kubectl run temp --image=busybox:1.36.1 --restart=Never -it --rm -- wget -O- blue:8080
```

**Use Helm to deploy an application from a Helm chart named web-app with specific values for replicas, image version, and environment variables. Validate the deployment, ensure the correct configuration is applied, and troubleshoot any Helm release issues.**

```bash
$ helm create web-app
# remove created templates from ./web-app/templates and values ./web-app/values.yaml
$ rm -f ./web-app/templates/* ./web/values.yaml
$ touch ./web-app/values.yaml
$ touch ./web-app/templates/deployment.yaml
$ helm install web-app ./web-app
```
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: {{ .Release.Name }} 
    custom-label : {{ .Values.label }}
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: {{ .Release.Name }}
        custom-label: {{ .Values.label }}
    spec:
      containers:
      - image: "{{ .Values.image.repository}}:{{ .Values.image.tag }}"
        name: {{ .Values.image.repository }}
        ports:
            - containerPort: {{ .Values.port }}
        env:
          {{- range .Values.env }}
          - name: {{ .name }}
            value: {{ .value | quote }}
          {{- end }}
```

```yaml
# values.yaml
replicas: 2
image:
    repository: nginx
    tag: "1.26.1"
port: 80
label: my-label
env:
  - name: ENVIRONMENT
    value: production
  - name: LOG_LEVEL
    value: debug
```

```bash
$ helm status web-app
$ kubectl get deployments
$ kubectl describe deployment web-app
$ kubectl get pods
$ kubectl logs <pod-name>
$ kubectl exec <pod>-name> --printenv
```

**Create a Kubernetes Deployment application and configure it to perform rolling updates. Update the application to a new version and monitor the update process. Roll back to the previous version.**

```bash
$ kubect create deployment app --image=nginx:1.26.1 --dry-run=client -o yaml > app.yaml
# Use apply for revision history and modify it for rollingupdate strategy
# Modify app.yaml and add RolingUpdate stratedy to deployment and maxUnavailable: 1
# spec.strategy.type: RollingUpdate
# spec.strategy.rollingUpdate.maxUnavailable: 1
$ kubectl apply -f app.yaml

# Change version of nginx:1.26.1 -> 1.26.2 and apply
$ kubectl apply -f app.yaml
$ kubectl rollout status deployment app
# wait for rollout
$ kubectl rollout history deployment app
# there shouble be revision 2
# check version of nginx 
$ kubectl describe deployment app
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: app
  name: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: app
    spec:
      containers:
      - image: nginx:1.26.2
        name: nginx
```


**Deploy a microservice application using a canary deployment strategy. Route a small percentage of traffic to the new version, monitor its performance, and gradually shift all traffic if successful.**

```bash
# First create deployemnts 
$ kubectl create deployment app1 --image nginx:1.26.1 --port=80 --dry-run=client -o yaml > app1.yaml
$ kubectl create deployment app2 --image nginx:1.26.2 --port=80 --dry-run=client -o yaml > app2.yaml
# Add common label to those deployemnt in spec.tempplate.metadata.labelc.deploy: canary 
$ kubeclt apply -f app1.yaml
$ kubeclt apply -f app2.yaml
# create servicem use expose for teplate
$ kubectl expose deployment app1 --port 8080 --target-port 80 --dry-run=client -o yaml > service.yaml
# Add this label into spec.selector.deploy: canary
# And add some meaningfull name for this service
$ kubectl apply -f service.yaml
# Checks using scale 
$ kubectl scale deployment app1 --replicas=0
$ kubectl run temp --image=busybox:1.36.1 --restart=Never -it --rm  -- wget -O- canary-service:8080
$ kubectl scale deployment app2 --replicas=0
# Should be error, beccause there is no pods 
$ kubectl run temp --image=busybox:1.36.1 --restart=Never -it --rm  -- wget -O- canary-service:8080
$ kubectl scale deployment app1 --replicas=1
$ kubeclt run temp --image=busybox:1.36.1 --restart=Never -it --rm  -- wget -O- canary-service:8080
```

```yaml
#app1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: app1
  name: app1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
      deploy: canary
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: app1
        deploy: canary
    spec:
      containers:
      - image: nginx:1.26.1
        name: nginx
        ports:
        - containerPort: 80
---
#app2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: app2
  name: app2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2
      deploy: canary
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: app2
        deploy: canary
    spec:
      containers:
      - image: nginx:1.26.1
        name: nginx
        ports:
        - containerPort: 80
---
#service.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: canary-service
  name: canary-service 
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 80
  selector:
    deploy: canary  
```


**Perform a Helm upgrade on an existing release with updated values for environment-specific configurations. Validate the upgrade and roll back if there are issues.**

```bash
$ helm install web-app ./web-app
# store previous config
$ helm get values web-app > old-values.yaml
$ helm upgrade web-app ./web-app --set image.tag="1.26.2"
$ helm status web-app
$ helm history web-app
$ helm rollback web-app 
```

**Use kubectl to deploy a StatefulSet for a service that requires ordered, persistent data. Scale the StatefulSet and verify the data persistence across replicas.**

```yaml
#statefullset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  serviceName: "my-app-service"
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
      - name: my-app-container
        image: nginx:1.26.1
        ports:
        - containerPort: 80
        volumeMounts:
        - name: my-app-storage
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: my-app-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: my-app
```

```bash
$ kubectl apply -f statefulset.yaml
# verify
$ kubectl get statefullsets
$ kubectl get pods -l app=my-app
$ kubectl exec -it my-app-0 -- /bin/bash
$ echo "Hello from my-app-0" > /usr/share/nginx/html/index.html
$ exit
$ kubectl exec -it my-app-0 -- cat /usr/share/nginx/html/index.html
$ kubectl scale statefulset my-app --replicas=5

$ kubectl get pvc
NAME                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-app-storage-my-app-0   Bound    pvc-76d8832d-cd9f-426b-af4f-736e882b1a15   1Gi        RWO            standard       13m
my-app-storage-my-app-1   Bound    pvc-ba5fe28b-b0d4-42ac-9d1b-0f57912e4321   1Gi        RWO            standard       11m
my-app-storage-my-app-2   Bound    pvc-3cf1f39d-f892-41f8-9185-814c45f49ef9   1Gi        RWO            standard       10m
my-app-storage-my-app-3   Bound    pvc-a142291d-2508-4c99-8edb-be0b3df66c9b   1Gi        RWO            standard       36s
my-app-storage-my-app-4   Bound    pvc-76cb44a9-7908-49f0-a544-96a7ce81d374   1Gi        RWO            standard       33s

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                             STORAGECLASS   REASON   AGE
example-pv                                 1Gi        RWO            Retain           Available                                     manual                  8m46s
pvc-3cf1f39d-f892-41f8-9185-814c45f49ef9   1Gi        RWO            Delete           Bound       default/my-app-storage-my-app-2   standard                10m
pvc-76cb44a9-7908-49f0-a544-96a7ce81d374   1Gi        RWO            Delete           Bound       default/my-app-storage-my-app-4   standard                39s
pvc-76d8832d-cd9f-426b-af4f-736e882b1a15   1Gi        RWO            Delete           Bound       default/my-app-storage-my-app-0   standard                13m
pvc-a142291d-2508-4c99-8edb-be0b3df66c9b   1Gi        RWO            Delete           Bound       default/my-app-storage-my-app-3   standard                42s
pvc-ba5fe28b-b0d4-42ac-9d1b-0f57912e4321   1Gi        RWO            Delete           Bound       default/my-app-storage-my-app-1   standard                12m
```


**Deploy an application using a Kubernetes Job that runs a batch process and terminates upon completion. Confirm the job execution and examine the logs for any errors.**

```yaml
---
#job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  template:
    spec:
      containers:
      - name: batch-job-container
        image: busybox
        command: ["sh", "-c", "echo 'Processing batch...'; sleep 10; echo 'Batch process completed.'"]
      restartPolicy: Never
  backoffLimit: 4
```

```bash
$ kubectl apply -f job.yaml
$ kubectl get jobs
$ kubectl get pods --selector=job-name=batch-job
$ kubectl logs <pod-name>
$ kubectl delete -f job.yaml
```
**Set up a Deployment that uses the RollingUpdate strategy with maxSurge and maxUnavailable settings configured. Test the effect of these settings during a deployment update.**

```yaml
---
#deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-update-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1       # max number of pods that will be created above the desired number
      maxUnavailable: 1 # maximum number of Pods that can be unavailable during the update process
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
        image: nginx:1.19
        ports:
        - containerPort: 80
```
```bash
$ kubectl apply -f deployment.yaml
# Edit deployment file
#      containers:
#      - name: my-container
#        image: nginx:1.21
$ kubectl apply -f deployment.yaml
# observe
$ kubectl rollout status deployment/rolling-update-deployment
$ kubectl get pods -l app=my-app -w
# rollback changes
$ kubectl rollout undo deployment/rolling-update-deployment
$ k delete -f deployment.yaml
```

**Use Helm to package a simple Node.js application, including values files for different environments (dev, staging, production). Deploy and validate the package in each environment.**

```yaml
# values.yaml
replicaCount: 2

image:
  repository: your-docker-repo/nodejs-app
  tag: "latest"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

nodeSelector: {}

tolerations: []

affinity: {}
```

```yaml
# values-dev.yaml
replicaCount: 1
image:
  tag: "dev"
resources:
  limits:
    cpu: 50m
    memory: 64Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

```yaml
# values-staging.yaml
replicaCount: 2
image:
  tag: "staging"
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

```yaml
# values-prod.yaml
replicaCount: 3
image:
  tag: "prod"
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 200m
    memory: 256Mi
```
The values.yaml file serves as the default configuration for your Helm chart.

```bash
# This command uses values.yaml as the base and overrides with the settings in values-dev.yaml.
$ helm install dev-node-js-app ./node-js-app -f values-dev.yaml
```

```bash
$ helm create node-js-app
$ helm package node-js-app
$ helm install dev-nodejs-app ./my-nodejs-app-0.1.0.tgz -f values-dev.yaml --namespace dev
$ kubectl get pods --namespace dev
$ kubectl logs -l app=my-nodejs-app --namespace dev
$ helm install staging-nodejs-app ./my-nodejs-app-0.1.0.tgz -f values-staging.yaml --namespace staging
$ kubectl get pods --namespace staging
$ kubectl logs -l app=my-nodejs-app --namespace staging
$ helm install prod-nodejs-app ./my-nodejs-app-0.1.0.tgz -f values-prod.yaml --namespace prod
$ kubectl get pods --namespace prod
$ kubectl logs -l app=my-nodejs-app --namespace prod
```

**Create a CronJob that runs a backup script every night at midnight. Validate the CronJob's execution and review the output logs.**

```yaml
# cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup
  labels:
    app: backup
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox:1.28
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Executing backup
          restartPolicy: OnFailure
      successfulJobsHistoryLimit: 3  # Retain the last 3 successful jobs
      failedJobsHistoryLimit: 1      # Retain the last failed job
```
```bash
$ kubectl apply -f cronjob.yaml
$ kubectl get cronjob backup
$ kubectl get jobs -l app=backup
$ kubectl get pods -l app=backup
$ kubectl logs <latest-cronjob-pod-name>
$ kubectl delete -f cronjob.yaml 
```

**Create a DaemonSet that runs a logging agent on every node in the cluster. Verify that logs from all nodes are being collected and processed.**

```yaml
# daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:latest
        resources:
          limits:
            memory: 200Mi
            cpu: 100m
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: containers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: containers
        hostPath:
          path: /var/lib/docker/containers
```
```bash
kubectl apply -f daemonset.yaml
kubectl get daemonset fluentd
kubectl get pods -l app=fluentd -o wide
kubectl logs fluentd-pod-name
kubectl delete -f daemonset.yaml
```

**Deploy a replicated application with a service for inter-pod communication. Verify that the application pods can discover each other using DNS.**

```yaml
# service-deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  labels:
    app: nginx
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
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

```bash
$kubectl apply -f service-deployment.yaml
$kubectl get pods -l app=nginx
$kubectl get deployments.apps nginx-app
$kubectl run -it --rm --restart=Never tmp --image=busybox:1.36.1 -- sh -c "wget -O- http://nginx-service"
$kubectl delete -f service-deployment.yaml
```
