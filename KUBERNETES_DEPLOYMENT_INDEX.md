# 🚀 Kubernetes Deployment Documentation - START HERE

## Welcome to the Order Taking Application Kubernetes Deployment Guide!

This is your **starting point** for deploying the Order Taking Spring Boot application to Kubernetes using Helm.

---

## 📖 Quick Navigation

### 🎯 New to Kubernetes Deployment?
**Start Here** → [KUBERNETES_DEPLOYMENT_SUMMARY.md](KUBERNETES_DEPLOYMENT_SUMMARY.md)

This comprehensive summary will guide you through:
- Choosing the right platform for your needs
- Understanding the documentation structure
- Getting started in 5 minutes

### 📚 Ready to Deploy?
**Choose Your Platform** → [KUBERNETES_DEPLOYMENT_README.md](KUBERNETES_DEPLOYMENT_README.md)

The main README contains:
- Links to all platform-specific guides
- Platform comparison table
- Quick start instructions
- Architecture overview

### ⚡ Need Commands Fast?
**Quick Reference** → [KUBERNETES_QUICK_REFERENCE.md](KUBERNETES_QUICK_REFERENCE.md)

Essential commands for:
- Windows (PowerShell)
- Linux (Bash)
- Minikube
- Rancher Desktop

---

## 🎯 Platform-Specific Guides

Choose the guide that matches your setup:

### Windows Users

| Platform | Guide | Best For |
|----------|-------|----------|
| **🔷 Minikube** | [KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md](KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md) | Learning, Lightweight setup |
| **🔶 Rancher Desktop** | [KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md](KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md) | Development, GUI preferred |

### Linux Users

| Platform | Guide | Best For |
|----------|-------|----------|
| **🔷 Minikube** | [KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md](KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md) | CI/CD, Lightweight setup |
| **🔶 Rancher Desktop** | [KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md](KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md) | Development, Full features |

---

## 📁 What's Included?

### Documentation Files (7 Files)
✅ **KUBERNETES_DEPLOYMENT_INDEX.md** - This file (start here!)  
✅ **KUBERNETES_DEPLOYMENT_SUMMARY.md** - Complete overview and decision guide  
✅ **KUBERNETES_DEPLOYMENT_README.md** - Main documentation index  
✅ **KUBERNETES_QUICK_REFERENCE.md** - Command reference card  
✅ **KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md** - Windows + Minikube guide  
✅ **KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md** - Windows + Rancher Desktop guide  
✅ **KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md** - Linux + Minikube guide  
✅ **KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md** - Linux + Rancher Desktop guide  

### Helm Chart Files (5 Files)
✅ **helm-chart/order-taking/Chart.yaml** - Chart metadata  
✅ **helm-chart/order-taking/values.yaml** - Configuration values  
✅ **helm-chart/order-taking/templates/deployment.yaml** - Deployment template  
✅ **helm-chart/order-taking/templates/service.yaml** - Service template  
✅ **helm-chart/order-taking/templates/_helpers.tpl** - Template helpers  

---

## 🚦 Getting Started (3 Steps)

### Step 1: Choose Your Path

**Are you using Windows or Linux?**
- Windows → Go to Step 2a
- Linux → Go to Step 2b

### Step 2a: Windows Users

**Do you prefer GUI or command-line?**
- **GUI/Easy Setup** → Use [Rancher Desktop Guide](KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md)
- **Command-line/Learning** → Use [Minikube Guide](KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md)

### Step 2b: Linux Users

**What's your primary goal?**
- **Full Development Environment** → Use [Rancher Desktop Guide](KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md)
- **Lightweight/CI-CD** → Use [Minikube Guide](KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md)

### Step 3: Deploy!

1. Open your chosen platform guide
2. Follow the step-by-step instructions
3. Keep [Quick Reference](KUBERNETES_QUICK_REFERENCE.md) handy
4. Deploy and enjoy! 🎉

---

## ⚡ Super Quick Start (For Experienced Users)

### If you have Rancher Desktop already installed:

**Windows:**
```powershell
cd "E:\Order Taking System"
mvn clean package -DskipTests
docker build -t order-taking:latest .
helm install order-taking-app .\helm-chart\order-taking
# Access: http://localhost:30080
```

**Linux:**
```bash
cd /path/to/order-taking-system
mvn clean package -DskipTests
docker build -t order-taking:latest .
helm install order-taking-app ./helm-chart/order-taking
# Access: http://localhost:30080
```

### If you have Minikube already installed:

**Windows:**
```powershell
minikube start --driver=docker --memory=4096 --cpus=2
minikube docker-env | Invoke-Expression
cd "E:\Order Taking System"
mvn clean package -DskipTests
docker build -t order-taking:latest .
helm install order-taking-app .\helm-chart\order-taking
minikube service order-taking-app-order-taking
```

**Linux:**
```bash
minikube start --driver=docker --memory=4096 --cpus=2
eval $(minikube docker-env)
cd /path/to/order-taking-system
mvn clean package -DskipTests
docker build -t order-taking:latest .
helm install order-taking-app ./helm-chart/order-taking
minikube service order-taking-app-order-taking
```

---

## 🎓 Recommended Reading Order

### For Beginners
1. **KUBERNETES_DEPLOYMENT_INDEX.md** ← You are here
2. **KUBERNETES_DEPLOYMENT_SUMMARY.md** - Understand the big picture
3. **Your platform-specific guide** - Follow step-by-step
4. **KUBERNETES_QUICK_REFERENCE.md** - Bookmark for commands

### For Intermediate Users
1. **KUBERNETES_DEPLOYMENT_INDEX.md** ← You are here
2. **KUBERNETES_DEPLOYMENT_README.md** - Review architecture
3. **Your platform-specific guide** - Jump to Build & Deploy sections
4. **KUBERNETES_QUICK_REFERENCE.md** - Use during deployment

### For Advanced Users
1. **KUBERNETES_DEPLOYMENT_INDEX.md** ← You are here
2. **helm-chart/order-taking/values.yaml** - Review configuration
3. **Your platform-specific guide** - Advanced topics only
4. **KUBERNETES_QUICK_REFERENCE.md** - Command reference

---

## 📊 Documentation Map

```
KUBERNETES_DEPLOYMENT_INDEX.md (START HERE!)
│
├─► KUBERNETES_DEPLOYMENT_SUMMARY.md
│   └─► Complete overview, decision guide, learning path
│
├─► KUBERNETES_DEPLOYMENT_README.md
│   └─► Main index, platform comparison, architecture
│
├─► KUBERNETES_QUICK_REFERENCE.md
│   └─► Essential commands, quick fixes, tips
│
└─► Platform-Specific Guides (Choose ONE):
    │
    ├─► KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md
    │   └─► Full guide for Windows + Minikube
    │
    ├─► KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md
    │   └─► Full guide for Windows + Rancher Desktop
    │
    ├─► KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md
    │   └─► Full guide for Linux + Minikube
    │
    └─► KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md
        └─► Full guide for Linux + Rancher Desktop
```

---

## 🔍 Find What You Need

### I need to...

**Understand the overall deployment process**  
→ Read [KUBERNETES_DEPLOYMENT_SUMMARY.md](KUBERNETES_DEPLOYMENT_SUMMARY.md)

**Choose between Minikube and Rancher Desktop**  
→ See comparison in [KUBERNETES_DEPLOYMENT_README.md](KUBERNETES_DEPLOYMENT_README.md)

**Install everything and deploy (Windows + Minikube)**  
→ Follow [KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md](KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md)

**Install everything and deploy (Windows + Rancher Desktop)**  
→ Follow [KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md](KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md)

**Install everything and deploy (Linux + Minikube)**  
→ Follow [KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md](KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md)

**Install everything and deploy (Linux + Rancher Desktop)**  
→ Follow [KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md](KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md)

**Find specific commands quickly**  
→ Use [KUBERNETES_QUICK_REFERENCE.md](KUBERNETES_QUICK_REFERENCE.md)

**Troubleshoot deployment issues**  
→ Check Troubleshooting section in your platform-specific guide

**Customize Helm deployment**  
→ Edit `helm-chart/order-taking/values.yaml`

**Understand Helm chart structure**  
→ Review files in `helm-chart/order-taking/templates/`

---

## ✅ Pre-Deployment Checklist

Before you start, ensure you have:

- [ ] **System Requirements Met**
  - Windows 10/11 or Linux (Ubuntu/Debian/Fedora/CentOS)
  - At least 4GB RAM available (8GB recommended)
  - 20GB free disk space
  - Admin/sudo privileges

- [ ] **Chosen Your Platform**
  - Decided on Minikube or Rancher Desktop
  - Read the comparison if unsure

- [ ] **Documentation Ready**
  - Platform-specific guide identified
  - Quick reference bookmarked
  - Troubleshooting section noted

- [ ] **Time Allocated**
  - First-time setup: 30-60 minutes
  - Experienced users: 10-15 minutes

---

## 🆘 Need Help?

### Step 1: Check Documentation
- Review the Troubleshooting section in your platform guide
- Search the Quick Reference for your issue
- Check the FAQ in the Summary document

### Step 2: Debug
```bash
# Check pod status
kubectl get pods

# View pod logs
kubectl logs <pod-name>

# Describe pod for events
kubectl describe pod <pod-name>

# Check cluster
kubectl cluster-info
kubectl get nodes
```

### Step 3: Common Solutions

**Pod not starting?**
→ Check your platform guide's "ImagePullBackOff" section

**Can't access application?**
→ Try port forwarding: `kubectl port-forward service/order-taking-app-order-taking 8080:8080`

**Cluster won't start?**
→ Check resource availability and restart your Kubernetes platform

---

## 🎯 Success Criteria

You've successfully deployed when:

✅ Kubernetes cluster is running  
✅ Docker image is built  
✅ Helm chart is deployed  
✅ Pod status shows "Running"  
✅ Service is created  
✅ Application is accessible in browser  
✅ Login page loads without errors  

---

## 🎉 What's Next?

After successful deployment:

1. **Test the Application**
   - Log in and test features
   - Create customers, add vegetables, place orders

2. **Explore Kubernetes**
   - View pods: `kubectl get pods`
   - Check logs: `kubectl logs <pod-name>`
   - Scale up: `kubectl scale deployment order-taking-app-order-taking --replicas=3`

3. **Learn Advanced Topics**
   - Configure ingress
   - Add persistent storage
   - Set up monitoring
   - Implement auto-scaling

4. **Customize Deployment**
   - Edit `values.yaml` for your needs
   - Add environment-specific configurations
   - Implement CI/CD pipelines

---

## 📞 Quick Links

| Link | Description |
|------|-------------|
| [Summary Document](KUBERNETES_DEPLOYMENT_SUMMARY.md) | Complete overview |
| [Main README](KUBERNETES_DEPLOYMENT_README.md) | Documentation index |
| [Quick Reference](KUBERNETES_QUICK_REFERENCE.md) | Command cheat sheet |
| [Windows + Minikube](KUBERNETES_DEPLOYMENT_WINDOWS_MINIKUBE.md) | Platform guide |
| [Windows + Rancher](KUBERNETES_DEPLOYMENT_WINDOWS_RANCHER.md) | Platform guide |
| [Linux + Minikube](KUBERNETES_DEPLOYMENT_LINUX_MINIKUBE.md) | Platform guide |
| [Linux + Rancher](KUBERNETES_DEPLOYMENT_LINUX_RANCHER.md) | Platform guide |

---

## 📌 Bookmark This Page!

This index page is your quick navigation hub. Bookmark it for easy access to all deployment documentation.

---

**Ready to deploy? Choose your guide above and let's get started! 🚀**

**Last Updated**: December 2025  
**Version**: 1.0  
**Application**: Order Taking System  
**Spring Boot**: 2.7.18  
**Java**: 17

