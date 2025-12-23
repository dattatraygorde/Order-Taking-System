# Quick Reference - Deploying to Tomcat 9

## ✅ What Was Fixed

Your application now works with Tomcat 9! Here's what changed:

1. **Downgraded Spring Boot:** 3.3.3 → 2.7.18 (Tomcat 9 compatible)
2. **Fixed imports:** jakarta.* → javax.* (all entities and controllers)
3. **Updated Security:** Spring Security 6 → Spring Security 5
4. **Added welcome page:** index.html at the root URL
5. **Configured web.xml:** For Servlet 3.1 compatibility

## 🚀 Quick Deploy (3 Easy Steps)

### Option 1: Automated (Recommended)
```bash
deploy-to-tomcat.bat
```
Done! Wait 15 seconds and open: http://localhost:8080/order-taking-0.0.1-SNAPSHOT/

### Option 2: Manual
```bash
# 1. Build
build.bat

# 2. Copy WAR file
copy "E:\Order Taking System\target\order-taking-0.0.1-SNAPSHOT.war" "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\"

# 3. Start Tomcat (if not running)
"C:\Program Files\Apache Software Foundation\Tomcat 9.0\bin\startup.bat"
```

## 🌐 Access URLs

| Page | URL |
|------|-----|
| Welcome Page | http://localhost:8080/order-taking-0.0.1-SNAPSHOT/ |
| Login | http://localhost:8080/order-taking-0.0.1-SNAPSHOT/login |
| Customers | http://localhost:8080/order-taking-0.0.1-SNAPSHOT/customers |
| Vegetables | http://localhost:8080/order-taking-0.0.1-SNAPSHOT/vegetables |
| New Order | http://localhost:8080/order-taking-0.0.1-SNAPSHOT/orders/new |
| Final Orders | http://localhost:8080/order-taking-0.0.1-SNAPSHOT/orders/final |

## 🔑 Login Credentials

- **Username:** admin
- **Password:** admin123

(Change these in `src/main/resources/application.yml`)

## 📁 Important Files

| File | Purpose |
|------|---------|
| `build.bat` | Build WAR file |
| `deploy-to-tomcat.bat` | Automated deployment script |
| `TOMCAT_DEPLOYMENT_GUIDE.md` | Complete deployment documentation |
| `target/order-taking-0.0.1-SNAPSHOT.war` | Deployable WAR file |

## 🔍 Checking Deployment Status

**View Tomcat Logs:**
```
C:\Program Files\Apache Software Foundation\Tomcat 9.0\logs\catalina.2025-11-16.log
```

**Look for these messages:**
```
Starting OrderTakingApplication
Started OrderTakingApplication in X.XXX seconds
```

## ❌ Troubleshooting

| Problem | Solution |
|---------|----------|
| Application doesn't start | Check Tomcat logs for errors |
| Port 8080 in use | Change port in Tomcat's `server.xml` |
| Database connection failed | Verify MySQL is running and credentials are correct |
| 404 Not Found | Wait for deployment to complete (15-30 seconds) |
| Login doesn't work | Check username/password in `application.yml` |

## 💡 Pro Tips

1. **Deploy as ROOT app** (access at http://localhost:8080/):
   - Rename WAR to `ROOT.war` before copying to webapps

2. **Hot reload during development:**
   - Use `mvn spring-boot:run` for embedded server
   - Access at http://localhost:8080/ (no context path)

3. **View application logs:**
   - Tomcat logs: `C:\Program Files\Apache Software Foundation\Tomcat 9.0\logs\`
   - Application logs: Configure in `application.yml`

4. **Database options:**
   - Development: Uses H2 in-memory (no setup needed)
   - Production: Configure MySQL in `application.yml`

## 📚 Need More Help?

See the complete guide: [TOMCAT_DEPLOYMENT_GUIDE.md](TOMCAT_DEPLOYMENT_GUIDE.md)

---

**✅ Your application is now ready for Tomcat 9 deployment!**

