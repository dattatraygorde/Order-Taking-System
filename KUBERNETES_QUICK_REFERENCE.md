# Kubernetes Deployment - Quick Reference Card

## 🚀 Quick Start Commands

### Windows (PowerShell)

#### Minikube
```powershell
# Start Minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Set Docker environment
minikube docker-env | Invoke-Expression

# Build and deploy
docker build -t order-taking:latest .
helm install order-taking-app .\helm-chart\order-taking

# Access application
minikube service order-taking-app-order-taking
```

#### Rancher Desktop
```powershell
# Build and deploy (Rancher Desktop must be running)
docker build -t order-taking:latest .
helm install order-taking-app .\helm-chart\order-taking

# Access application
Start-Process http://localhost:30080
```

### Linux (Bash)

#### Minikube
```bash
# Start Minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Set Docker environment
eval $(minikube docker-env)

# Build and deploy
docker build -t order-taking:latest .
helm install order-taking-app ./helm-chart/order-taking

# Access application
minikube service order-taking-app-order-taking
```

#### Rancher Desktop
```bash
# Build and deploy (Rancher Desktop must be running)
docker build -t order-taking:latest .
helm install order-taking-app ./helm-chart/order-taking

# Access application
xdg-open http://localhost:30080
```

---

## 📦 Essential Commands

### Helm Commands

| Command | Description |
|---------|-------------|
| `helm install <name> <chart>` | Install a chart |
| `helm list` | List releases |
| `helm status <name>` | Show release status |
| `helm upgrade <name> <chart>` | Upgrade release |
| `helm rollback <name>` | Rollback to previous version |
| `helm uninstall <name>` | Uninstall release |
| `helm lint <chart>` | Validate chart |

### kubectl Commands

| Command | Description |
|---------|-------------|
| `kubectl get pods` | List pods |
| `kubectl get services` | List services |
| `kubectl get deployments` | List deployments |
| `kubectl logs <pod>` | View pod logs |
| `kubectl describe pod <pod>` | Describe pod details |
| `kubectl exec -it <pod> -- bash` | SSH into pod |
| `kubectl port-forward svc/<service> 8080:8080` | Port forward |
| `kubectl delete pod <pod>` | Delete pod |

### Docker Commands

| Command | Description |
|---------|-------------|
| `docker images` | List images |
| `docker ps` | List running containers |
| `docker build -t <name>:<tag> .` | Build image |
| `docker rmi <image>` | Remove image |
| `docker logs <container>` | View container logs |

---

## 🔍 Troubleshooting Quick Fixes

### Pod Won't Start (ImagePullBackOff)

**Minikube:**
```bash
# Set Docker environment
eval $(minikube docker-env)  # Linux
minikube docker-env | Invoke-Expression  # Windows

# Rebuild image
docker build -t order-taking:latest .
```

**Rancher Desktop:**
```bash
# Ensure image exists
docker images | grep order-taking

# Rebuild if needed
docker build -t order-taking:latest .
```

### Pod Crashes (CrashLoopBackOff)

```bash
# Check logs
kubectl logs <pod-name>

# Check previous logs
kubectl logs <pod-name> --previous

# Describe pod for events
kubectl describe pod <pod-name>
```

### Can't Access Application

```bash
# Method 1: Port forward
kubectl port-forward service/order-taking-app-order-taking 8080:8080
# Access: http://localhost:8080

# Method 2: Check service
kubectl get svc
kubectl describe svc order-taking-app-order-taking

# Method 3 (Minikube): Get URL
minikube service order-taking-app-order-taking --url
```

### Cluster Won't Start

**Minikube:**
```bash
# Delete and recreate
minikube delete
minikube start --driver=docker --memory=4096 --cpus=2
```

**Rancher Desktop:**
- Open Rancher Desktop GUI
- Troubleshooting → Reset Kubernetes
- Or: Troubleshooting → Factory Reset

---

## 📊 Status Check Commands

```bash
# Overall cluster health
kubectl cluster-info
kubectl get nodes

# Application status
helm list
kubectl get all

# Detailed pod status
kubectl get pods -o wide

# Watch pod status
kubectl get pods -w

# Resource usage
kubectl top nodes
kubectl top pods

# Events
kubectl get events --sort-by='.lastTimestamp'
```

---

## 🔧 Configuration Values

### Common values.yaml Overrides

```bash
# Scale replicas
helm upgrade order-taking-app ./helm-chart/order-taking --set replicaCount=3

# Change service type
helm upgrade order-taking-app ./helm-chart/order-taking --set service.type=LoadBalancer

# Update image tag
helm upgrade order-taking-app ./helm-chart/order-taking --set image.tag=v2.0

# Set environment variable
helm upgrade order-taking-app ./helm-chart/order-taking \
  --set env[0].name=SPRING_PROFILES_ACTIVE \
  --set env[0].value=prod
```

---

## 🌐 Access URLs

| Platform | Method | URL |
|----------|--------|-----|
| **Minikube** | Service | `minikube service order-taking-app-order-taking` |
| **Minikube** | IP:Port | `http://$(minikube ip):30080` |
| **Rancher Desktop** | NodePort | `http://localhost:30080` |
| **Both** | Port Forward | `http://localhost:8080` (after port-forward) |

---

## 🧹 Cleanup Commands

```bash
# Uninstall application
helm uninstall order-taking-app

# Stop cluster
minikube stop                    # Minikube
# (Close Rancher Desktop GUI)    # Rancher Desktop

# Delete cluster
minikube delete                  # Minikube

# Remove images
docker rmi order-taking:latest

# Clean Docker
docker system prune -a
```

---

## 📁 File Locations

### Windows
- Project: `E:\Order Taking System`
- Helm Chart: `E:\Order Taking System\helm-chart\order-taking`
- Built WAR: `E:\Order Taking System\target\order-taking-0.0.1-SNAPSHOT.war`

### Linux
- Project: `/path/to/order-taking-system` or `/mnt/e/Order Taking System`
- Helm Chart: `./helm-chart/order-taking`
- Built WAR: `./target/order-taking-0.0.1-SNAPSHOT.war`

---

## 🎯 Build Commands

```bash
# Navigate to project
cd "E:\Order Taking System"              # Windows
cd /mnt/e/Order\ Taking\ System          # Linux (WSL)

# Clean build
mvn clean

# Build without tests
mvn package -DskipTests

# Build with tests
mvn package

# Clean and build
mvn clean package -DskipTests
```

---

## 🔐 Security Best Practices

```bash
# Don't use 'latest' tag in production
# Instead, use version tags
docker build -t order-taking:1.0.0 .

# Use secrets for sensitive data
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secret

# Scan images for vulnerabilities
docker scan order-taking:latest

# Use resource limits (already in values.yaml)
# Review and adjust as needed
```

---

## 📈 Scaling Commands

```bash
# Scale deployment manually
kubectl scale deployment order-taking-app-order-taking --replicas=3

# Enable auto-scaling
kubectl autoscale deployment order-taking-app-order-taking \
  --cpu-percent=50 --min=1 --max=10

# Check auto-scaler
kubectl get hpa
```

---

## 🐛 Debug Commands

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=order-taking -o jsonpath='{.items[0].metadata.name}')

# View logs (follow)
kubectl logs -f $POD_NAME

# Execute commands in pod
kubectl exec -it $POD_NAME -- bash
kubectl exec -it $POD_NAME -- env
kubectl exec -it $POD_NAME -- ps aux

# Test from inside cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Then: wget -O- http://order-taking-app-order-taking:8080
```

---

## 💡 Tips & Tricks

### Minikube Tips

```bash
# Dashboard
minikube dashboard

# SSH into VM
minikube ssh

# Pause/unpause
minikube pause
minikube unpause

# Add-ons
minikube addons list
minikube addons enable ingress
minikube addons enable metrics-server
```

### Rancher Desktop Tips

- Use GUI for easy cluster management
- Built-in Traefik ingress controller
- Container runtime switch: dockerd ↔ containerd
- Port forwarding handled automatically
- WSL integration (Windows)

### General Tips

```bash
# Use aliases
alias k=kubectl
alias h=helm
alias kgp='kubectl get pods'
alias kgs='kubectl get services'

# Watch for changes
watch kubectl get pods

# JSON output for scripting
kubectl get pods -o json
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Show labels
kubectl get pods --show-labels
```

---

## 🎓 Learning Resources

- **Kubernetes**: https://kubernetes.io/docs/tutorials/
- **Helm**: https://helm.sh/docs/intro/quickstart/
- **Minikube**: https://minikube.sigs.k8s.io/docs/start/
- **Rancher Desktop**: https://docs.rancherdesktop.io/

---

**Print this page for quick reference during deployment!**

**Last Updated**: December 2025

