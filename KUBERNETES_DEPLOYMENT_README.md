# Kubernetes Deployment Guides - Order Taking Application

This repository contains comprehensive deployment guides for deploying the Order Taking Spring Boot application on Kubernetes using Helm.

## Available Deployment Guides

We have created **4 separate deployment guides** to cover different operating systems and Kubernetes platforms:

### Windows Deployment Guides

| Platform | Guide | Description |
|----------|-------|-------------|
| **Minikube** | [KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md](KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md) | Deploy on Windows using Minikube |
| **Rancher Desktop** | [KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md](KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md) | Deploy on Windows using Rancher Desktop |

### Linux Deployment Guides

| Platform | Guide | Description |
|----------|-------|-------------|
| **Minikube** | [KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md](KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md) | Deploy on Linux using Minikube |
| **Rancher Desktop** | [KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md](KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md) | Deploy on Linux using Rancher Desktop |

---

## Quick Start Guide

### Choose Your Platform

1. **Determine your Operating System**: Windows or Linux
2. **Choose Kubernetes Platform**:
   - **Minikube**: Lightweight, great for learning and testing
   - **Rancher Desktop**: Full-featured, includes GUI, better for development

### Recommended Combinations

- **Beginners**: Windows + Rancher Desktop (easiest setup with GUI)
- **Developers**: Linux + Rancher Desktop (best development experience)
- **Learning K8s**: Any OS + Minikube (focuses on core Kubernetes concepts)
- **CI/CD**: Linux + Minikube (lightweight, scriptable)

---

## What's Included

Each deployment guide includes:

### 📋 Comprehensive Instructions
- Prerequisites and system requirements
- Step-by-step installation of required tools
- Kubernetes cluster setup
- Docker image building
- Helm chart deployment
- Application access methods

### 🛠️ Complete Helm Charts
Located in `helm-chart/order-taking/`:
- `Chart.yaml` - Chart metadata
- `values.yaml` - Configurable values
- `templates/deployment.yaml` - Deployment configuration
- `templates/service.yaml` - Service configuration
- `templates/_helpers.tpl` - Template helpers

### 🔍 Troubleshooting
- Common issues and solutions
- Debug commands
- Log analysis

### 🚀 Advanced Topics
- Ingress configuration
- Persistent storage
- Auto-scaling
- Monitoring and metrics
- Automation scripts

---

## Prerequisites Overview

### Common Requirements (All Platforms)

- **RAM**: At least 4GB available (8GB recommended)
- **Disk Space**: 20GB free
- **Network**: Stable internet connection

### Platform-Specific Tools

#### Windows
- Docker Desktop OR Rancher Desktop
- Chocolatey (package manager)
- PowerShell
- Java JDK 17
- Maven

#### Linux
- Docker Engine OR Rancher Desktop
- Package manager (apt/dnf/yum)
- Bash
- Java JDK 17
- Maven

---

## Deployment Workflow

```
┌─────────────────────────────────────────────────────┐
│  1. Install Prerequisites                           │
│     - Java, Maven, Docker, kubectl, Helm            │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  2. Setup Kubernetes Cluster                        │
│     - Minikube or Rancher Desktop                   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  3. Build Application                               │
│     - mvn clean package                             │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  4. Build Docker Image                              │
│     - docker build -t order-taking:latest .         │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  5. Deploy with Helm                                │
│     - helm install order-taking-app ./helm-chart    │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│  6. Access Application                              │
│     - http://localhost:30080                        │
└─────────────────────────────────────────────────────┘
```

---

## Helm Chart Structure

```
helm-chart/
└── order-taking/
    ├── Chart.yaml              # Chart metadata
    ├── values.yaml             # Default configuration values
    └── templates/
        ├── _helpers.tpl        # Template helper functions
        ├── deployment.yaml     # Kubernetes Deployment
        └── service.yaml        # Kubernetes Service
```

### Key Configuration Options (values.yaml)

```yaml
# Number of application replicas
replicaCount: 1

# Docker image configuration
image:
  repository: order-taking
  tag: latest
  pullPolicy: IfNotPresent

# Service configuration
service:
  type: NodePort
  port: 8080
  nodePort: 30080

# Resource limits
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Environment variables
env:
  - name: SPRING_PROFILES_ACTIVE
    value: "dev"
```

---

## Quick Command Reference

### Build and Deploy (Any Platform)

```bash
# Build application
mvn clean package -DskipTests

# Build Docker image
docker build -t order-taking:latest .

# Deploy with Helm
helm install order-taking-app ./helm-chart/order-taking

# Check status
kubectl get pods
kubectl get services

# Access application
# Minikube: minikube service order-taking-app-order-taking
# Rancher Desktop: http://localhost:30080
```

### Manage Deployment

```bash
# Upgrade deployment
helm upgrade order-taking-app ./helm-chart/order-taking

# Rollback deployment
helm rollback order-taking-app

# View logs
kubectl logs <pod-name>

# Scale deployment
kubectl scale deployment order-taking-app-order-taking --replicas=3

# Uninstall
helm uninstall order-taking-app
```

---

## Platform Comparison

| Feature | Minikube | Rancher Desktop |
|---------|----------|-----------------|
| **Ease of Setup** | Moderate | Easy (GUI) |
| **Resource Usage** | Light | Moderate |
| **GUI** | Dashboard only | Full GUI |
| **Container Runtime** | Docker/containerd | Docker/containerd |
| **Ingress** | Addon | Built-in (Traefik) |
| **Registry** | None | Built-in |
| **Multi-cluster** | No | Yes |
| **Updates** | Manual | Auto-update available |
| **Best For** | Learning, CI/CD | Development, Testing |

---

## Troubleshooting Quick Links

### Common Issues

**Image Pull Errors:**
- Ensure image is built in correct Docker environment
- Check imagePullPolicy setting
- Verify image exists: `docker images`

**Pod Crashes:**
- Check logs: `kubectl logs <pod-name>`
- Check resources: `kubectl describe pod <pod-name>`
- Review application configuration

**Service Not Accessible:**
- Verify service type and ports
- Check firewall settings
- Use port-forward as alternative: `kubectl port-forward svc/order-taking-app-order-taking 8080:8080`

**Cluster Won't Start:**
- Check system resources (RAM, disk space)
- Review platform logs
- Try resetting cluster

For detailed troubleshooting, refer to the specific guide for your platform.

---

## Support and Resources

### Documentation
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Helm Official Docs](https://helm.sh/docs/)
- [Minikube Docs](https://minikube.sigs.k8s.io/docs/)
- [Rancher Desktop Docs](https://docs.rancherdesktop.io/)

### Tools Documentation
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Docker Documentation](https://docs.docker.com/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)

---

## Contributing

If you find issues or have improvements:
1. Document the issue
2. Test the solution
3. Update the relevant guide
4. Submit changes

---

## Version Information

- **Guides Version**: 1.0
- **Date**: December 2025
- **Spring Boot Version**: 2.7.18
- **Java Version**: 17
- **Helm Chart Version**: 1.0.0
- **App Version**: 0.0.1-SNAPSHOT

---

## Next Steps

After successful deployment:

1. **Secure Your Application**
   - Configure authentication
   - Add TLS/SSL certificates
   - Implement network policies

2. **Add Monitoring**
   - Deploy Prometheus
   - Set up Grafana dashboards
   - Configure alerts

3. **Implement CI/CD**
   - Automate builds
   - Automate deployments
   - Add testing pipelines

4. **Production Readiness**
   - Configure high availability
   - Set up backup and recovery
   - Implement logging strategy

---

## License

This project is part of the Order Taking System application.

---

## Contact & Support

For questions or issues with deployment:
1. Check the troubleshooting section in your platform-specific guide
2. Review Kubernetes and Helm documentation
3. Check application logs for errors

---

**Happy Deploying! 🚀**

