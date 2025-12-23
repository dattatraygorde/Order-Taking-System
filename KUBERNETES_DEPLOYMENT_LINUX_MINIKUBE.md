# Deployment Guide: Spring Boot Application on Kubernetes Using Helm
## Linux + Rancher Desktop

This guide walks through deploying the Order Taking Spring Boot application on Kubernetes using Helm on **Linux** with **Rancher Desktop**.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Install Required Tools](#install-required-tools)
3. [Setup Rancher Desktop](#setup-rancher-desktop)
4. [Build Docker Image](#build-docker-image)
5. [Deploy with Helm](#deploy-with-helm)
6. [Access the Application](#access-application)
7. [Verify Deployment](#verify-deployment)
8. [Troubleshooting](#troubleshooting)
9. [Cleanup](#cleanup)

---

## Prerequisites

- Linux distribution (Ubuntu 20.04+, Debian, Fedora, CentOS, etc.)
- Sudo privileges
- At least 8GB RAM (4GB available for Rancher Desktop)
- 20GB free disk space
- Stable internet connection
- Desktop environment (GNOME, KDE, XFCE, etc.)

---

## Install Required Tools

### 1. Update System Packages

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt upgrade -y
```

**Fedora:**
```bash
sudo dnf update -y
```

**CentOS/RHEL:**
```bash
sudo yum update -y
```

### 2. Install Dependencies

**Ubuntu/Debian:**
```bash
sudo apt install -y curl wget git ca-certificates gnupg lsb-release
```

**Fedora:**
```bash
sudo dnf install -y curl wget git ca-certificates
```

### 3. Install Rancher Desktop

**Method 1: Using AppImage (All Distributions)**

```bash
# Download latest Rancher Desktop AppImage
cd ~/Downloads
wget https://github.com/rancher-sandbox/rancher-desktop/releases/latest/download/Rancher.Desktop-$(uname -m).AppImage

# Make it executable
chmod +x Rancher.Desktop-*.AppImage

# Move to /usr/local/bin (optional)
sudo mv Rancher.Desktop-*.AppImage /usr/local/bin/rancher-desktop

# Install FUSE (required for AppImage)
# Ubuntu/Debian
sudo apt install -y libfuse2

# Fedora
sudo dnf install -y fuse fuse-libs

# Run Rancher Desktop
rancher-desktop
```

**Method 2: Using DEB package (Ubuntu/Debian)**

```bash
# Download DEB package
cd ~/Downloads
LATEST_VERSION=$(curl -s https://api.github.com/repos/rancher-sandbox/rancher-desktop/releases/latest | grep tag_name | cut -d '"' -f 4)
wget "https://github.com/rancher-sandbox/rancher-desktop/releases/download/${LATEST_VERSION}/rancher-desktop-${LATEST_VERSION#v}-amd64.deb"

# Install
sudo apt install -y ./rancher-desktop-*.deb
```

**Method 3: Using RPM package (Fedora/CentOS/RHEL)**

```bash
# Download RPM package
cd ~/Downloads
LATEST_VERSION=$(curl -s https://api.github.com/repos/rancher-sandbox/rancher-desktop/releases/latest | grep tag_name | cut -d '"' -f 4)
wget "https://github.com/rancher-sandbox/rancher-desktop/releases/download/${LATEST_VERSION}/rancher-desktop-${LATEST_VERSION#v}.x86_64.rpm"

# Install
sudo dnf install -y ./rancher-desktop-*.rpm
# Or for CentOS/RHEL
sudo yum install -y ./rancher-desktop-*.rpm
```

### 4. Verify Installation

```bash
# Check if kubectl is available (installed by Rancher Desktop)
kubectl version --client

# Check if docker is available
docker version

# Check if helm is available
helm version
```

If commands are not found, add to PATH:
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH="$HOME/.rd/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 5. Install Java JDK 17 (if not already installed)

**Ubuntu/Debian:**
```bash
sudo apt install -y openjdk-17-jdk
```

**Fedora:**
```bash
sudo dnf install -y java-17-openjdk java-17-openjdk-devel
```

Verify:
```bash
java -version
```

### 6. Install Maven (if not already installed)

**Ubuntu/Debian:**
```bash
sudo apt install -y maven
```

**Fedora:**
```bash
sudo dnf install -y maven
```

Verify:
```bash
mvn -version
```

---

## Setup Rancher Desktop

### 1. Launch Rancher Desktop

From applications menu or terminal:
```bash
rancher-desktop
```

### 2. Initial Configuration

On first launch, configure:

**Welcome Screen:**
- Accept license agreement

**Kubernetes Settings:**
- **Kubernetes Version**: Select latest stable version (e.g., v1.28.x)
- **Container Runtime**: Choose `dockerd (moby)` for Docker CLI compatibility
  - Alternative: `containerd` (use nerdctl instead of docker)
- **Memory (GB)**: 4 or more
- **CPUs**: 2 or more
- Click "Apply"

Wait for Kubernetes to start (check status in main window).

### 3. Verify Rancher Desktop Status

Check main window shows:
- Kubernetes: Running (green)
- Container Engine: Running (green)

From terminal:
```bash
# Check Kubernetes
kubectl get nodes
```

Expected output:
```
NAME              STATUS   ROLES                  AGE   VERSION
lima-rancher      Ready    control-plane,master   5m    v1.28.x
```

```bash
# Check Docker
docker ps

# Check cluster info
kubectl cluster-info
```

### 4. Configure Resources (if needed)

Open Rancher Desktop → Preferences:

- **Virtual Machine**: Adjust memory and CPU
- **Container Engine**: Select dockerd or containerd
- **Kubernetes**: Select version and port
- **WSL**: (N/A for Linux)

---

## Build Docker Image

### 1. Navigate to Project Directory

```bash
cd /path/to/order-taking-system
# Or if on Windows partition:
cd /mnt/e/Order\ Taking\ System/
```

### 2. Build the Application WAR

```bash
mvn clean package -DskipTests
```

### 3. Build Docker Image

Since Rancher Desktop includes Docker runtime, build directly:

```bash
docker build -t order-taking:latest .
```

**If using containerd instead of dockerd:**
```bash
nerdctl build -t order-taking:latest .
```

### 4. Verify Image

**With Docker:**
```bash
docker images | grep order-taking
```

**With containerd/nerdctl:**
```bash
nerdctl images | grep order-taking
```

Expected output:
```
order-taking   latest   <image-id>   <time>   <size>
```

---

## Deploy with Helm

### 1. Navigate to Helm Chart Directory

```bash
cd /path/to/order-taking-system/helm-chart
# Or:
cd /mnt/e/Order\ Taking\ System/helm-chart
```

### 2. Validate Helm Chart

```bash
helm lint order-taking
```

### 3. Create Namespace (Optional)

```bash
kubectl create namespace order-taking-ns
```

### 4. Dry Run Deployment

Preview what Helm will deploy:
```bash
helm install order-taking-app ./order-taking --dry-run --debug
```

Or with custom namespace:
```bash
helm install order-taking-app ./order-taking --namespace order-taking-ns --dry-run --debug
```

### 5. Deploy Application

**Default namespace:**
```bash
helm install order-taking-app ./order-taking
```

**Custom namespace:**
```bash
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

```bash
# List Helm releases
helm list

# Check Kubernetes resources
kubectl get deployments
kubectl get pods
kubectl get services
```

Wait for pods to be running:
```bash
kubectl get pods -w
```

Press `Ctrl+C` to stop watching.

---

## Access the Application

### Method 1: Using NodePort

Rancher Desktop on Linux exposes NodePort services on localhost.

Access the application at:
```
http://localhost:30080
```

Or use the cluster IP:
```bash
# Get node IP
kubectl get nodes -o wide

# Access at:
# http://<NODE-IP>:30080
```

Test with curl:
```bash
curl http://localhost:30080
```

### Method 2: Using Port Forwarding

```bash
kubectl port-forward service/order-taking-app-order-taking 8080:8080
```

Access at: http://localhost:8080

Keep the terminal open while using the application.

### Method 3: Open in Browser

```bash
# Using default browser
xdg-open http://localhost:30080

# Or
firefox http://localhost:30080 &
google-chrome http://localhost:30080 &
```

---

## Verify Deployment

### 1. Check Pod Status and Logs

Get pod name:
```bash
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=order-taking -o jsonpath='{.items[0].metadata.name}')
echo "Pod name: $POD_NAME"
```

View logs:
```bash
kubectl logs $POD_NAME
```

Follow logs in real-time:
```bash
kubectl logs -f $POD_NAME
```

### 2. Check Service Details

```bash
kubectl describe service order-taking-app-order-taking
```

### 3. Check Deployment Details

```bash
kubectl describe deployment order-taking-app-order-taking
```

### 4. Inspect Pod

```bash
kubectl describe pod $POD_NAME
```

### 5. Test Application Endpoint

```bash
# Test health
curl http://localhost:30080

# Test with formatted output
curl -s http://localhost:30080 | head -50

# Check HTTP status
curl -I http://localhost:30080
```

### 6. Check Resource Usage

```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods
```

---

## Troubleshooting

### Issue: Rancher Desktop not starting

**Check system resources:**
```bash
free -h
nproc
```

**Check logs:**
```bash
# View Rancher Desktop logs
journalctl --user -u rancher-desktop

# Or check log files
ls -la ~/.local/share/rancher-desktop/logs/
cat ~/.local/share/rancher-desktop/logs/background.log
```

**Reset Rancher Desktop:**
```bash
# Stop Rancher Desktop
pkill -f rancher-desktop

# Remove data (will delete all images and containers!)
rm -rf ~/.local/share/rancher-desktop
rm -rf ~/.rd

# Start again
rancher-desktop
```

### Issue: kubectl commands not working

**Check PATH:**
```bash
echo $PATH | grep -o '.rd/bin'
```

If not found, add to PATH:
```bash
echo 'export PATH="$HOME/.rd/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Check context:**
```bash
kubectl config current-context
kubectl config get-contexts
```

Set context if needed:
```bash
kubectl config use-context rancher-desktop
```

### Issue: Pod not starting (ImagePullBackOff)

**Check if image exists:**
```bash
docker images | grep order-taking
# Or with containerd:
nerdctl images | grep order-taking
```

**Ensure imagePullPolicy is correct:**
Edit `values.yaml`:
```yaml
image:
  pullPolicy: IfNotPresent
```

**Redeploy:**
```bash
helm uninstall order-taking-app
helm install order-taking-app ./order-taking
```

### Issue: CrashLoopBackOff

**Check pod logs:**
```bash
kubectl logs $POD_NAME
```

**Check previous container logs:**
```bash
kubectl logs $POD_NAME --previous
```

**Common causes:**
- Application configuration errors
- Insufficient memory/CPU
- Port conflicts
- Missing environment variables
- Database connection issues

**Increase resources:**
Edit `values.yaml`:
```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

Upgrade:
```bash
helm upgrade order-taking-app ./order-taking
```

### Issue: Service not accessible on localhost:30080

**Check service type and port:**
```bash
kubectl get svc order-taking-app-order-taking -o yaml | grep -A5 spec
```

**Verify NodePort:**
```bash
kubectl describe svc order-taking-app-order-taking | grep NodePort
```

**Test from inside cluster:**
```bash
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside pod:
wget -O- http://order-taking-app-order-taking:8080
exit
```

**Use port forwarding as alternative:**
```bash
kubectl port-forward svc/order-taking-app-order-taking 8080:8080
```

### Issue: Docker/nerdctl commands not working

**If using dockerd:**
```bash
docker info
# If fails, check Rancher Desktop is running
```

**If using containerd:**
Use `nerdctl` instead of `docker`:
```bash
nerdctl ps
nerdctl images
```

**Check container runtime in Rancher Desktop:**
- Open Rancher Desktop
- Go to Preferences → Container Engine
- Verify `dockerd (moby)` is selected

### Issue: Permission errors

**Add user to docker group (if using dockerd):**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Check file permissions:**
```bash
ls -la ~/.rd/
ls -la ~/.local/share/rancher-desktop/
```

---

## Cleanup

### 1. Uninstall Helm Release

```bash
helm uninstall order-taking-app
```

Or with namespace:
```bash
helm uninstall order-taking-app --namespace order-taking-ns
```

### 2. Delete Namespace (if created)

```bash
kubectl delete namespace order-taking-ns
```

### 3. Verify Cleanup

```bash
kubectl get all
helm list
```

### 4. Remove Docker Images (Optional)

**With Docker:**
```bash
docker rmi order-taking:latest
```

**With nerdctl:**
```bash
nerdctl rmi order-taking:latest
```

### 5. Stop Rancher Desktop

From GUI: Click "Quit" in the application menu

Or from terminal:
```bash
pkill -f rancher-desktop
```

### 6. Clean up completely (Optional)

**Remove all data:**
```bash
rm -rf ~/.local/share/rancher-desktop
rm -rf ~/.rd
rm -rf ~/.config/rancher-desktop
```

---

## Useful Commands Reference

### Helm Commands
```bash
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
```bash
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

# Edit deployment
kubectl edit deployment order-taking-app-order-taking

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Get resource usage
kubectl top nodes
kubectl top pods
```

### Docker/Nerdctl Commands

**With Docker (dockerd):**
```bash
docker ps
docker images
docker logs <container-id>
docker exec -it <container-id> /bin/bash
docker system prune -a
```

**With nerdctl (containerd):**
```bash
nerdctl ps
nerdctl images
nerdctl logs <container-id>
nerdctl exec -it <container-id> /bin/bash
nerdctl system prune -a
```

### Rancher Desktop Commands
```bash
# Check Rancher Desktop processes
ps aux | grep rancher

# View logs
tail -f ~/.local/share/rancher-desktop/logs/background.log

# Check version
rancher-desktop --version
```

---

## Advanced Configuration

### Enable Ingress with Traefik

Rancher Desktop includes Traefik ingress controller.

1. **Update values.yaml:**
```yaml
ingress:
  enabled: true
  className: traefik
  annotations: {}
  hosts:
    - host: order-taking.local
      paths:
        - path: /
          pathType: Prefix
```

2. **Add to /etc/hosts:**
```bash
echo "127.0.0.1 order-taking.local" | sudo tee -a /etc/hosts
```

3. **Upgrade Helm release:**
```bash
helm upgrade order-taking-app ./order-taking
```

4. **Access:**
```bash
xdg-open http://order-taking.local
```

### Persistent Storage

Rancher Desktop supports local-path provisioner.

**Create PVC:**
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

**Apply:**
```bash
kubectl apply -f pvc.yaml
```

### Enable Metrics and Monitoring

**Install metrics-server:**
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**Check resource usage:**
```bash
kubectl top nodes
kubectl top pods
```

### Auto-scaling

**Create HPA:**
```bash
kubectl autoscale deployment order-taking-app-order-taking \
  --cpu-percent=50 \
  --min=1 \
  --max=10
```

**Check HPA status:**
```bash
kubectl get hpa
kubectl describe hpa order-taking-app-order-taking
```

---

## Automation Scripts

### Deployment Script (deploy.sh)

```bash
#!/bin/bash
set -e

PROJECT_DIR="/path/to/order-taking-system"
HELM_DIR="$PROJECT_DIR/helm-chart"

echo "=== Building application ==="
cd "$PROJECT_DIR"
mvn clean package -DskipTests

echo "=== Building Docker image ==="
docker build -t order-taking:latest .

echo "=== Deploying with Helm ==="
cd "$HELM_DIR"
helm upgrade --install order-taking-app ./order-taking

echo "=== Waiting for deployment ==="
kubectl wait --for=condition=available --timeout=300s \
  deployment/order-taking-app-order-taking

echo "=== Deployment complete ==="
echo "Access application at: http://localhost:30080"

# Open in browser
xdg-open http://localhost:30080
```

Make executable and run:
```bash
chmod +x deploy.sh
./deploy.sh
```

### Cleanup Script (cleanup.sh)

```bash
#!/bin/bash
set -e

echo "=== Uninstalling Helm release ==="
helm uninstall order-taking-app

echo "=== Removing Docker images ==="
docker rmi order-taking:latest || true

echo "=== Cleanup complete ==="
```

Make executable and run:
```bash
chmod +x cleanup.sh
./cleanup.sh
```

---

## Next Steps

1. **Configure Ingress**: Use Traefik for advanced routing
2. **Add Database**: Deploy PostgreSQL/MySQL with persistent storage
3. **Set up Monitoring**: Deploy Prometheus and Grafana
4. **Configure Secrets**: Use Kubernetes secrets for sensitive data
5. **Implement CI/CD**: Automate deployment with GitLab CI/Jenkins
6. **Enable Auto-scaling**: Configure HPA and VPA
7. **Add Logging**: Deploy EFK stack (Elasticsearch, Fluentd, Kibana)

---

## Additional Resources

- [Rancher Desktop Documentation](https://docs.rancherdesktop.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [nerdctl Documentation](https://github.com/containerd/nerdctl)

---

**Date**: December 2025
**Version**: 1.0
**Platform**: Linux + Rancher Desktop

