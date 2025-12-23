# Deployment Guide: Spring Boot Application on Kubernetes Using Helm
## Linux + Minikube

This guide walks through deploying the Order Taking Spring Boot application on Kubernetes using Helm on **Linux** with **Minikube**.

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

- Linux distribution (Ubuntu 20.04+, Debian, Fedora, CentOS, etc.)
- Sudo privileges
- At least 4GB RAM available
- 20GB free disk space
- Stable internet connection

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

### 2. Install Docker

**Ubuntu/Debian:**
```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

**Fedora:**
```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

Verify Docker installation:
```bash
docker --version
docker run hello-world
```

### 3. Install kubectl

```bash
# Download latest release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Validate binary (optional)
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### 4. Install Helm

```bash
# Download installation script
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Or using package manager (Ubuntu/Debian)
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Verify installation
helm version
```

### 5. Install Minikube

```bash
# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

### 6. Install Java JDK 17 (if not already installed)

**Ubuntu/Debian:**
```bash
sudo apt install -y openjdk-17-jdk
```

**Fedora:**
```bash
sudo dnf install -y java-17-openjdk java-17-openjdk-devel
```

Verify installation:
```bash
java -version
```

### 7. Install Maven (if not already installed)

**Ubuntu/Debian:**
```bash
sudo apt install -y maven
```

**Fedora:**
```bash
sudo dnf install -y maven
```

Verify installation:
```bash
mvn -version
```

---

## Setup Minikube

### 1. Start Minikube

Using Docker driver (recommended):
```bash
minikube start --driver=docker --memory=4096 --cpus=2
```

Or using KVM2 driver:
```bash
# Install KVM2 driver first
sudo apt install -y libvirt-daemon-system libvirt-clients bridge-utils qemu-kvm
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo usermod -aG libvirt $USER
newgrp libvirt

# Install docker-machine-driver-kvm2
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2
sudo install docker-machine-driver-kvm2 /usr/local/bin/

# Start minikube with KVM2
minikube start --driver=kvm2 --memory=4096 --cpus=2
```

### 2. Verify Minikube Status

```bash
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

```bash
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable ingress
```

List all addons:
```bash
minikube addons list
```

### 4. Configure kubectl to use Minikube

```bash
kubectl config use-context minikube
```

Verify:
```bash
kubectl cluster-info
kubectl get nodes
```

---

## Build Docker Image

### 1. Navigate to Project Directory

```bash
cd /path/to/order-taking-system
# Or if on Windows drive:
cd /mnt/e/Order\ Taking\ System/
```

### 2. Build the Application WAR

```bash
mvn clean package -DskipTests
```

### 3. Set Minikube Docker Environment

This ensures Docker images are built directly in Minikube's Docker daemon:

```bash
eval $(minikube docker-env)
```

**Note:** This setting is only valid for the current terminal session. If you open a new terminal, run this command again.

### 4. Build Docker Image

```bash
docker build -t order-taking:latest .
```

### 5. Verify Image

```bash
docker images | grep order-taking
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

### 3. Dry Run Deployment

Preview what Helm will deploy:
```bash
helm install order-taking-app ./order-taking --dry-run --debug
```

### 4. Deploy Application

```bash
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

```bash
helm list
kubectl get deployments
kubectl get pods
kubectl get services
```

Wait for pods to be in `Running` status:
```bash
kubectl get pods -w
```

Press `Ctrl+C` to stop watching.

---

## Access the Application

### Method 1: Using Minikube Service

```bash
minikube service order-taking-app-order-taking
```

This will automatically open the application in your default browser.

To get the URL without opening browser:
```bash
minikube service order-taking-app-order-taking --url
```

### Method 2: Using NodePort

Get the Minikube IP:
```bash
minikube ip
```

Access the application at:
```
http://<minikube-ip>:30080
```

Example:
```bash
# Get IP
MINIKUBE_IP=$(minikube ip)
echo "Application URL: http://$MINIKUBE_IP:30080"

# Open in browser (if GUI available)
xdg-open "http://$MINIKUBE_IP:30080"
```

### Method 3: Using Port Forwarding

```bash
kubectl port-forward service/order-taking-app-order-taking 8080:8080
```

Access at: http://localhost:8080

Keep the terminal open while using the application.

### Method 4: Using Minikube Tunnel (for LoadBalancer)

If you change service type to LoadBalancer:
```bash
minikube tunnel
```

This requires sudo password and must remain running.

---

## Verify Deployment

### 1. Check Pod Logs

Get pod name:
```bash
kubectl get pods
```

View logs:
```bash
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=order-taking -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD_NAME
```

Follow logs:
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

### 4. Access Kubernetes Dashboard

```bash
minikube dashboard
```

This opens the Kubernetes dashboard in your browser.

### 5. Test Application Health

```bash
# Get service URL
SERVICE_URL=$(minikube service order-taking-app-order-taking --url)

# Test endpoint
curl $SERVICE_URL

# Or with formatted output
curl -s $SERVICE_URL | head -20
```

---

## Troubleshooting

### Issue: Pod is not starting

Check pod events:
```bash
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=order-taking -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod $POD_NAME
```

Check logs:
```bash
kubectl logs $POD_NAME
```

### Issue: ImagePullBackOff error

The image might not be available in Minikube's Docker daemon. Ensure you ran:
```bash
eval $(minikube docker-env)
```

Then rebuild the image:
```bash
docker build -t order-taking:latest .
```

Verify the image exists:
```bash
docker images | grep order-taking
```

### Issue: CrashLoopBackOff

Check application logs:
```bash
kubectl logs $POD_NAME
```

Check previous container logs:
```bash
kubectl logs $POD_NAME --previous
```

Common causes:
- Application configuration issues
- Database connection problems
- Insufficient resources
- Port conflicts

Increase resources if needed:
```bash
minikube delete
minikube start --driver=docker --memory=6144 --cpus=4
```

### Issue: Service not accessible

Check service status:
```bash
kubectl get svc
```

Verify NodePort is configured:
```bash
kubectl describe svc order-taking-app-order-taking
```

Test from within cluster:
```bash
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Then inside the pod:
wget -O- http://order-taking-app-order-taking:8080
```

### Issue: Minikube won't start

Check system requirements:
```bash
# Check virtualization support
egrep -c '(vmx|svm)' /proc/cpuinfo
# Should return a number > 0

# Check Docker is running
docker ps
```

Delete and recreate:
```bash
minikube delete
minikube start --driver=docker --memory=4096 --cpus=2
```

Check Minikube logs:
```bash
minikube logs
```

### Issue: Permission denied errors

Add user to docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

Logout and login again, or restart your system.

---

## Cleanup

### 1. Uninstall Helm Release

```bash
helm uninstall order-taking-app
```

### 2. Verify Deletion

```bash
kubectl get all
```

### 3. Stop Minikube

```bash
minikube stop
```

### 4. Delete Minikube Cluster (Optional)

```bash
minikube delete
```

### 5. Remove Docker Images (Optional)

```bash
docker rmi order-taking:latest
```

### 6. Clean up Docker resources

```bash
docker system prune -a
```

---

## Useful Commands Reference

### Helm Commands
```bash
# List all releases
helm list

# Get release status
helm status order-taking-app

# Upgrade release
helm upgrade order-taking-app ./order-taking

# Upgrade with value overrides
helm upgrade order-taking-app ./order-taking --set replicaCount=2

# Rollback to previous version
helm rollback order-taking-app

# Get release history
helm history order-taking-app

# Uninstall release
helm uninstall order-taking-app
```

### Kubernetes Commands
```bash
# Get all resources
kubectl get all

# Get pods with labels
kubectl get pods -l app.kubernetes.io/name=order-taking

# Get pods with wide output
kubectl get pods -o wide

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

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

### Minikube Commands
```bash
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

# Disable addon
minikube addons disable <addon-name>

# Get dashboard URL
minikube dashboard --url

# Pause/unpause cluster
minikube pause
minikube unpause

# Get service URL
minikube service <service-name> --url
```

### Docker Commands (within Minikube context)
```bash
# Set Minikube Docker environment
eval $(minikube docker-env)

# List images in Minikube
docker images

# List containers
docker ps

# View logs
docker logs <container-id>

# Unset Minikube Docker environment
eval $(minikube docker-env -u)
```

---

## Advanced Configuration

### Enable Ingress

1. Enable ingress addon:
```bash
minikube addons enable ingress
```

2. Update `values.yaml`:
```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: order-taking.local
      paths:
        - path: /
          pathType: Prefix
```

3. Add to `/etc/hosts`:
```bash
echo "$(minikube ip) order-taking.local" | sudo tee -a /etc/hosts
```

4. Upgrade Helm release:
```bash
helm upgrade order-taking-app ./order-taking
```

5. Access at: http://order-taking.local

### Persistent Storage

Create a PersistentVolumeClaim:
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
  storageClassName: standard
```

Apply:
```bash
kubectl apply -f pvc.yaml
```

### Auto-scaling

Enable metrics-server:
```bash
minikube addons enable metrics-server
```

Create HPA:
```bash
kubectl autoscale deployment order-taking-app-order-taking --cpu-percent=50 --min=1 --max=10
```

Check HPA status:
```bash
kubectl get hpa
```

---

## Automation Scripts

### Start Script (start.sh)

```bash
#!/bin/bash
set -e

echo "Starting Minikube..."
minikube start --driver=docker --memory=4096 --cpus=2

echo "Setting Docker environment..."
eval $(minikube docker-env)

echo "Building Docker image..."
docker build -t order-taking:latest .

echo "Deploying with Helm..."
helm install order-taking-app ./helm-chart/order-taking

echo "Waiting for deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/order-taking-app-order-taking

echo "Getting service URL..."
minikube service order-taking-app-order-taking --url

echo "Deployment complete!"
```

Make it executable:
```bash
chmod +x start.sh
./start.sh
```

### Stop Script (stop.sh)

```bash
#!/bin/bash
set -e

echo "Uninstalling Helm release..."
helm uninstall order-taking-app

echo "Stopping Minikube..."
minikube stop

echo "Cleanup complete!"
```

Make it executable:
```bash
chmod +x stop.sh
./stop.sh
```

---

## Next Steps

1. **Configure Ingress**: Set up ingress controller for better routing
2. **Add Persistent Storage**: Configure persistent volumes for data
3. **Set up Monitoring**: Deploy Prometheus and Grafana
4. **Configure Auto-scaling**: Enable HPA (Horizontal Pod Autoscaler)
5. **Add CI/CD**: Integrate with Jenkins/GitLab CI
6. **Database Integration**: Deploy and connect to PostgreSQL/MySQL

---

## Additional Resources

- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

**Date**: December 2025
**Version**: 1.0
**Platform**: Linux + Minikube

