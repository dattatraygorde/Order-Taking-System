# Deployment Guide: Spring Boot Application on Kubernetes Using Helm
## Windows + Rancher Desktop

This guide walks through deploying the Order Taking Spring Boot application on Kubernetes using Helm on **Windows** with **Rancher Desktop**.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Install Required Tools](#install-required-tools)
3. [Setup Rancher Desktop](#setup-rancher-desktop)
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
- At least 8GB RAM (4GB available for Rancher Desktop)
- 20GB free disk space
- Stable internet connection
- WSL 2 (recommended) or Hyper-V enabled

---

## Install Required Tools

### 1. Install WSL 2 (Recommended)

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

Restart your computer if prompted.

Set WSL 2 as default:
```powershell
wsl --set-default-version 2
```

Install Ubuntu (optional but recommended):
```powershell
wsl --install -d Ubuntu
```

### 2. Install Rancher Desktop

Download Rancher Desktop from: https://rancherdesktop.io/

**Installation Steps:**
1. Run the installer (`Rancher.Desktop.Setup.exe`)
2. Follow the installation wizard
3. Launch Rancher Desktop
4. On first launch, configure:
   - **Kubernetes Version**: Select latest stable version (e.g., v1.28.x)
   - **Container Runtime**: Choose `dockerd (moby)` for Docker CLI compatibility
   - **WSL**: Enable WSL integration (if using WSL 2)
5. Click "Accept" and wait for initialization

### 3. Verify Rancher Desktop Installation

Open a new PowerShell or Command Prompt window:

```powershell
# Check Kubernetes
kubectl version --client
kubectl cluster-info

# Check Docker
docker version

# Check Helm (included with Rancher Desktop)
helm version
```

### 4. Install Java JDK 17 (if not already installed)

Using Chocolatey:
```powershell
# Install Chocolatey first (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Java
choco install openjdk17 -y
```

Verify:
```powershell
java -version
```

### 5. Install Maven (if not already installed)

```powershell
choco install maven -y
```

Verify:
```powershell
mvn -version
```

---

## Setup Rancher Desktop

### 1. Start Rancher Desktop

- Launch Rancher Desktop from the Start Menu
- Wait for Kubernetes to be in "Running" state (check system tray icon)
- The icon should show green when ready

### 2. Configure Rancher Desktop Settings

Open Rancher Desktop Settings:

**Kubernetes Settings:**
- Version: Select latest stable
- Port: 6443 (default)
- Enable Kubernetes: ✓

**Container Engine:**
- Select: `dockerd (moby)`
- Enable: ✓

**WSL Integration (if using WSL):**
- Enable integration with default distro: ✓
- Enable for additional distros: Select your distros

**Resources:**
- Memory: 4GB or more
- CPUs: 2 or more

### 3. Verify Kubernetes Cluster

```powershell
kubectl get nodes
```

Expected output:
```
NAME                   STATUS   ROLES                  AGE   VERSION
rancher-desktop        Ready    control-plane,master   5m    v1.28.x
```

```powershell
kubectl cluster-info
```

### 4. Verify Docker

```powershell
docker ps
docker info
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

### 3. Build Docker Image

Since Rancher Desktop includes Docker runtime, build directly:

```powershell
docker build -t order-taking:latest .
```

### 4. Verify Image

```powershell
docker images | findstr order-taking
```

Expected output:
```
order-taking   latest   <image-id>   <time>   <size>
```

### 5. Tag Image for Local Registry (Optional)

If using Rancher's local registry:
```powershell
docker tag order-taking:latest localhost:5000/order-taking:latest
docker push localhost:5000/order-taking:latest
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

### 3. Create Namespace (Optional)

```powershell
kubectl create namespace order-taking-ns
```

### 4. Dry Run Deployment

Preview what Helm will deploy:
```powershell
helm install order-taking-app ./order-taking --dry-run --debug
```

Or with custom namespace:
```powershell
helm install order-taking-app ./order-taking --namespace order-taking-ns --dry-run --debug
```

### 5. Deploy Application

**Default namespace:**
```powershell
helm install order-taking-app ./order-taking
```

**Custom namespace:**
```powershell
helm install order-taking-app ./order-taking --namespace order-taking-ns --create-namespace
```

Expected output:
```
NAME: order-taking-app
LAST DEPLOYED: <timestamp>
NAMESPACE: default
STATUS: deployed
REVISION: 1
```

### 6. Check Deployment Status

```powershell
# List Helm releases
helm list

# Check Kubernetes resources
kubectl get deployments
kubectl get pods
kubectl get services
```

Wait for pods to be running:
```powershell
kubectl get pods -w
```

Press `Ctrl+C` to stop watching.

---

## Access the Application

### Method 1: Using NodePort

1. Get the service details:
```powershell
kubectl get service order-taking-app-order-taking
```

2. Access via localhost (Rancher Desktop automatically exposes NodePort):
```
http://localhost:30080
```

Or use the Windows host IP:
```powershell
# Get your local IP
ipconfig | findstr IPv4
```

Access at:
```
http://<your-ip>:30080
```

### Method 2: Using Port Forwarding

```powershell
kubectl port-forward service/order-taking-app-order-taking 8080:8080
```

Access at: http://localhost:8080

Keep the terminal open while using the application.

### Method 3: Using Rancher Desktop Kubernetes Explorer

1. Open Rancher Desktop
2. Click on "Kubernetes" in the sidebar
3. Navigate to Services
4. Find `order-taking-app-order-taking`
5. Click the URL or port to open in browser

---

## Verify Deployment

### 1. Check Pod Status and Logs

Get pod name:
```powershell
kubectl get pods
```

View logs:
```powershell
kubectl logs <pod-name>
```

Follow logs in real-time:
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

### 4. Inspect Pod

```powershell
kubectl describe pod <pod-name>
```

### 5. Test Application Endpoint

```powershell
# Using curl (install via: choco install curl)
curl http://localhost:30080

# Using PowerShell
Invoke-WebRequest -Uri http://localhost:30080
```

### 6. Access Application in Browser

Open your web browser and navigate to:
```
http://localhost:30080
```

You should see the Order Taking application login page.

---

## Troubleshooting

### Issue: Rancher Desktop not starting

**Solutions:**
1. Check WSL status:
   ```powershell
   wsl --status
   wsl --list --verbose
   ```

2. Restart WSL:
   ```powershell
   wsl --shutdown
   ```
   Then restart Rancher Desktop

3. Reset Rancher Desktop:
   - Open Rancher Desktop
   - Go to Troubleshooting → Reset Kubernetes
   - Or completely reset: Troubleshooting → Factory Reset

### Issue: Pod not starting (ImagePullBackOff)

Check if image exists locally:
```powershell
docker images | findstr order-taking
```

Ensure imagePullPolicy is set correctly in values.yaml:
```yaml
image:
  pullPolicy: IfNotPresent
```

Redeploy:
```powershell
helm uninstall order-taking-app
helm install order-taking-app ./order-taking
```

### Issue: CrashLoopBackOff

Check pod logs for errors:
```powershell
kubectl logs <pod-name>
```

Check previous container logs:
```powershell
kubectl logs <pod-name> --previous
```

Common causes:
- Application configuration errors
- Insufficient memory/CPU
- Port conflicts
- Database connection issues

### Issue: Service not accessible on localhost:30080

1. Verify service is running:
   ```powershell
   kubectl get svc
   ```

2. Check NodePort configuration:
   ```powershell
   kubectl describe svc order-taking-app-order-taking
   ```

3. Verify Rancher Desktop port forwarding:
   - Open Rancher Desktop
   - Check Port Forwarding settings

4. Try port forwarding manually:
   ```powershell
   kubectl port-forward svc/order-taking-app-order-taking 8080:8080
   ```

### Issue: kubectl commands not working

1. Verify Rancher Desktop is running
2. Check PATH environment variable includes Rancher Desktop binaries
3. Restart PowerShell/Command Prompt
4. Verify context:
   ```powershell
   kubectl config current-context
   kubectl config get-contexts
   ```

### Issue: Docker commands not working

1. Ensure Container Engine is set to `dockerd (moby)` in Rancher Desktop settings
2. Restart Rancher Desktop
3. Check Docker daemon:
   ```powershell
   docker info
   ```

### Issue: High Memory Usage

1. Reduce allocated resources in Rancher Desktop settings
2. Reduce replica count:
   ```powershell
   kubectl scale deployment order-taking-app-order-taking --replicas=1
   ```

3. Adjust resource limits in values.yaml:
   ```yaml
   resources:
     limits:
       memory: 256Mi
     requests:
       memory: 128Mi
   ```

---

## Cleanup

### 1. Uninstall Helm Release

```powershell
helm uninstall order-taking-app
```

Or with namespace:
```powershell
helm uninstall order-taking-app --namespace order-taking-ns
```

### 2. Delete Namespace (if created)

```powershell
kubectl delete namespace order-taking-ns
```

### 3. Verify Cleanup

```powershell
kubectl get all
helm list
```

### 4. Remove Docker Images (Optional)

```powershell
docker rmi order-taking:latest
```

### 5. Stop Rancher Desktop

- Right-click Rancher Desktop icon in system tray
- Select "Quit Rancher Desktop"

Or reset completely:
- Open Rancher Desktop
- Troubleshooting → Reset Kubernetes
- Or: Troubleshooting → Factory Reset

---

## Useful Commands Reference

### Helm Commands
```powershell
# List releases
helm list --all-namespaces

# Get release details
helm status order-taking-app

# Upgrade release
helm upgrade order-taking-app ./order-taking

# Upgrade with value overrides
helm upgrade order-taking-app ./order-taking --set replicaCount=2

# Rollback
helm rollback order-taking-app

# History
helm history order-taking-app

# Uninstall
helm uninstall order-taking-app
```

### Kubernetes Commands
```powershell
# Get all resources
kubectl get all

# Get resources in specific namespace
kubectl get all -n order-taking-ns

# Get pods with details
kubectl get pods -o wide

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Copy files to/from pod
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file

# Scale deployment
kubectl scale deployment order-taking-app-order-taking --replicas=3

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Get resource usage
kubectl top nodes
kubectl top pods
```

### Docker Commands
```powershell
# List containers
docker ps

# List all containers (including stopped)
docker ps -a

# View logs
docker logs <container-id>

# Inspect container
docker inspect <container-id>

# Execute command in container
docker exec -it <container-id> /bin/bash

# Remove unused images
docker image prune -a
```

### Rancher Desktop CLI
```powershell
# Check version
rdctl --version

# List virtual machines
rdctl list-settings

# Start Kubernetes
rdctl start

# Shutdown
rdctl shutdown
```

---

## Advanced Configuration

### Enable Ingress Controller

Rancher Desktop includes Traefik by default. To use it:

1. Update `values.yaml`:
```yaml
ingress:
  enabled: true
  className: traefik
  hosts:
    - host: order-taking.local
      paths:
        - path: /
          pathType: Prefix
```

2. Add entry to `C:\Windows\System32\drivers\etc\hosts`:
```
127.0.0.1 order-taking.local
```

3. Upgrade Helm release:
```powershell
helm upgrade order-taking-app ./order-taking
```

4. Access at: http://order-taking.local

### Enable Metrics and Monitoring

Install metrics-server:
```powershell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Check resource usage:
```powershell
kubectl top nodes
kubectl top pods
```

### Persistent Storage

Rancher Desktop supports local-path provisioner by default.

Create PersistentVolumeClaim:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: order-taking-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: local-path
```

---

## Next Steps

1. **Configure Ingress**: Use Traefik for advanced routing
2. **Add Database**: Deploy PostgreSQL/MySQL with persistent storage
3. **Set up Monitoring**: Deploy Prometheus and Grafana
4. **Configure Secrets**: Use Kubernetes secrets for sensitive data
5. **Implement CI/CD**: Automate deployment with GitHub Actions
6. **Enable Auto-scaling**: Configure HPA

---

## Additional Resources

- [Rancher Desktop Documentation](https://docs.rancherdesktop.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

---

**Date**: December 2025
**Version**: 1.0
**Platform**: Windows + Rancher Desktop

