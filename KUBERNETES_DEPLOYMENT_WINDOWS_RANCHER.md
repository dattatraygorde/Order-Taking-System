# Deployment Guide: Spring Boot Application on Kubernetes Using Helm
## Windows + Minikube

This guide walks through deploying the Order Taking Spring Boot application on Kubernetes using Helm on **Windows** with **Minikube**.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Install Required Tools](#install-required-tools)
3. [Setup Minikube](#setup-minikube)
4. [Build Docker Image](#build-docker-image)
5. [Deploy with Helm](#deploy-with-helm)
6. [Access the Application](#access-the-application)
7. [Verify Deployment](#verify-deployment)
8. [Troubleshooting](#troubleshooting)
9. [Cleanup](#cleanup)

---

## Prerequisites

- Windows 10/11 (64-bit)
- Administrator privileges
- At least 4GB RAM available
- 20GB free disk space
- Stable internet connection

---

## Install Required Tools

### 1. Install Chocolatey (Package Manager)

Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### 2. Install Docker Desktop

Download and install Docker Desktop from: https://www.docker.com/products/docker-desktop

After installation:
- Open Docker Desktop
- Go to Settings → General
- Ensure "Use WSL 2 based engine" is checked (if using WSL 2)
- Click "Apply & Restart"

### 3. Install kubectl

```powershell
choco install kubernetes-cli -y
```

Verify installation:
```powershell
kubectl version --client
```

### 4. Install Helm

```powershell
choco install kubernetes-helm -y
```

Verify installation:
```powershell
helm version
```

### 5. Install Minikube

```powershell
choco install minikube -y
```

Verify installation:
```powershell
minikube version
```

### 6. Install Java JDK 17 (if not already installed)

```powershell
choco install openjdk17 -y
```

Verify installation:
```powershell
java -version
```

### 7. Install Maven (if not already installed)

```powershell
choco install maven -y
```

Verify installation:
```powershell
mvn -version
```

---

## Setup Minikube

### 1. Start Minikube

Using Docker driver (recommended):
```powershell
minikube start --driver=docker --memory=4096 --cpus=2
```

Or using Hyper-V driver:
```powershell
minikube start --driver=hyperv --memory=4096 --cpus=2
```

### 2. Verify Minikube Status

```powershell
minikube status
```

Expected output:
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### 3. Enable Minikube Addons (Optional)

```powershell
minikube addons enable metrics-server
minikube addons enable dashboard
```

### 4. Configure kubectl to use Minikube

```powershell
kubectl config use-context minikube
```

Verify:
```powershell
kubectl cluster-info
kubectl get nodes
```

---

## Build Docker Image

### 1. Navigate to Project Directory

```powershell
cd "E:\Order Taking System"
```

### 2. Build the Application WAR

```powershell
mvn clean package -DskipTests
```

### 3. Set Minikube Docker Environment

This ensures Docker images are built directly in Minikube's Docker daemon:

```powershell
minikube docker-env | Invoke-Expression
```

### 4. Build Docker Image

```powershell
docker build -t order-taking:latest .
```

### 5. Verify Image

```powershell
docker images | findstr order-taking
```

Expected output:
```
order-taking   latest   <image-id>   <time>   <size>
```

---

## Deploy with Helm

### 1. Navigate to Helm Chart Directory

```powershell
cd "E:\Order Taking System\helm-chart"
```

### 2. Validate Helm Chart

```powershell
helm lint order-taking
```

### 3. Dry Run Deployment

Preview what Helm will deploy:
```powershell
helm install order-taking-app ./order-taking --dry-run --debug
```

### 4. Deploy Application

```powershell
helm install order-taking-app ./order-taking
```

Expected output:
```
NAME: order-taking-app
LAST DEPLOYED: <timestamp>
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

### 5. Check Deployment Status

```powershell
helm list
kubectl get deployments
kubectl get pods
kubectl get services
```

Wait for pods to be in `Running` status:
```powershell
kubectl get pods -w
```

Press `Ctrl+C` to stop watching.

---

## Access the Application

### Method 1: Using Minikube Service

```powershell
minikube service order-taking-app-order-taking
```

This will automatically open the application in your default browser.

### Method 2: Using NodePort

Get the Minikube IP:
```powershell
minikube ip
```

Access the application at:
```
http://<minikube-ip>:30080
```

Example:
```
http://192.168.49.2:30080
```

### Method 3: Using Port Forwarding

```powershell
kubectl port-forward service/order-taking-app-order-taking 8080:8080
```

Access at: http://localhost:8080

---

## Verify Deployment

### 1. Check Pod Logs

Get pod name:
```powershell
kubectl get pods
```

View logs:
```powershell
kubectl logs <pod-name>
```

Follow logs:
```powershell
kubectl logs -f <pod-name>
```

### 2. Check Service Details

```powershell
kubectl describe service order-taking-app-order-taking
```

### 3. Check Deployment Details

```powershell
kubectl describe deployment order-taking-app-order-taking
```

### 4. Access Kubernetes Dashboard (Optional)

```powershell
minikube dashboard
```

### 5. Test Application Health

```powershell
# Get service URL
$SERVICE_URL = minikube service order-taking-app-order-taking --url

# Test endpoint
curl $SERVICE_URL
```

---

## Troubleshooting

### Issue: Pod is not starting

Check pod events:
```powershell
kubectl describe pod <pod-name>
```

Check logs:
```powershell
kubectl logs <pod-name>
```

### Issue: ImagePullBackOff error

The image might not be available in Minikube's Docker daemon. Ensure you ran:
```powershell
minikube docker-env | Invoke-Expression
```

Then rebuild the image:
```powershell
docker build -t order-taking:latest .
```

### Issue: CrashLoopBackOff

Check application logs:
```powershell
kubectl logs <pod-name>
```

Common causes:
- Application configuration issues
- Database connection problems
- Insufficient resources

### Issue: Service not accessible

Check service status:
```powershell
kubectl get svc
```

Verify NodePort is configured:
```powershell
kubectl describe svc order-taking-app-order-taking
```

### Issue: Minikube won't start

Delete and recreate:
```powershell
minikube delete
minikube start --driver=docker --memory=4096 --cpus=2
```

### Check Minikube logs:
```powershell
minikube logs
```

---

## Cleanup

### 1. Uninstall Helm Release

```powershell
helm uninstall order-taking-app
```

### 2. Verify Deletion

```powershell
kubectl get all
```

### 3. Stop Minikube

```powershell
minikube stop
```

### 4. Delete Minikube Cluster (Optional)

```powershell
minikube delete
```

### 5. Remove Docker Images (Optional)

```powershell
docker rmi order-taking:latest
```

---

## Useful Commands Reference

### Helm Commands
```powershell
# List all releases
helm list

# Get release status
helm status order-taking-app

# Upgrade release
helm upgrade order-taking-app ./order-taking

# Rollback to previous version
helm rollback order-taking-app

# Get release history
helm history order-taking-app
```

### Kubernetes Commands
```powershell
# Get all resources
kubectl get all

# Get pods with labels
kubectl get pods -l app.kubernetes.io/name=order-taking

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/sh

# Scale deployment
kubectl scale deployment order-taking-app-order-taking --replicas=3

# Get events
kubectl get events --sort-by='.lastTimestamp'
```

### Minikube Commands
```powershell
# Check status
minikube status

# SSH into Minikube VM
minikube ssh

# Get Minikube IP
minikube ip

# List addons
minikube addons list

# Enable addon
minikube addons enable <addon-name>
```

---

## Next Steps

1. **Configure Ingress**: Set up ingress controller for better routing
2. **Add Persistent Storage**: Configure persistent volumes for data
3. **Set up Monitoring**: Deploy Prometheus and Grafana
4. **Configure Auto-scaling**: Enable HPA (Horizontal Pod Autoscaler)
5. **Add CI/CD**: Integrate with Jenkins/GitHub Actions

---

## Additional Resources

- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Desktop Documentation](https://docs.docker.com/desktop/windows/)

---

**Date**: December 2025
**Version**: 1.0
**Platform**: Windows + Minikube

