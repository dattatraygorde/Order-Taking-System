# Order Taking Application (Spring Boot, Java 17, MySQL, Thymeleaf)

An admin-only web app to manage customers and vegetables, take orders with multiple items, print order confirmations, and view consolidated daily orders.

## Features

- Admin login (Spring Security, in-memory user)
- Tabs:
  - Customers: Add/Edit/Delete customers
  - Vegetables: Add/Edit/Delete vegetables
  - Order Taking: Select customer, date, add multiple vegetables with quantities; printable confirmation
  - Final Orders: Consolidated totals by vegetable for a given date; list of orders for that date

## Tech Stack

- Java 17, Spring Boot 2.7.18 (compatible with Tomcat 9)
- Spring MVC, Spring Data JPA (Hibernate), Spring Security 5
- Thymeleaf, HTML/CSS/JS
- MySQL (or H2 for development)

## Getting Started

1. Create MySQL database:
   ```sql
   CREATE DATABASE order_taking CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
   ```
2. Update `src/main/resources/application.yml` with your MySQL credentials.
3. Optionally change the in-memory admin credentials in `application.yml`:
   ```yaml
   app:
     admin:
       username: admin
       password: admin123
   ```
4. Build and run:
   ```bash
   mvn spring-boot:run
   # or
   mvn clean package
   java -jar target/order-taking-0.0.1-SNAPSHOT.jar
   ```
5. Open http://localhost:8080 to see the welcome page, or go directly to http://localhost:8080/login to log in with your admin credentials.

## Deployment to Tomcat 9

This application is configured to be deployed as a WAR file to Apache Tomcat 9.

### Quick Deployment (Windows)

Simply run the automated deployment script:
```bash
deploy-to-tomcat.bat
```

This script will:
- Build the WAR file
- Stop Tomcat
- Remove old deployment
- Copy new WAR file
- Start Tomcat

### Manual Deployment

1. Build the WAR file:
   ```bash
   mvn clean package -DskipTests
   # or use: build.bat
   ```

2. The WAR file will be created at `target/order-taking-0.0.1-SNAPSHOT.war`

3. Copy the WAR file to your Tomcat's `webapps` directory

4. Start Tomcat, and the application will be auto-deployed

5. Access the application at:
   - Welcome page: `http://localhost:8080/order-taking-0.0.1-SNAPSHOT/`
   - Login page: `http://localhost:8080/order-taking-0.0.1-SNAPSHOT/login`

**Note:** The welcome page (`index.html`) is publicly accessible and provides quick links to all application features.

### Detailed Deployment Guide

For complete deployment instructions, troubleshooting, and compatibility information, see:
- **[TOMCAT_DEPLOYMENT_GUIDE.md](TOMCAT_DEPLOYMENT_GUIDE.md)** - Comprehensive deployment guide

**Important:** This application uses **Spring Boot 2.7.18** for compatibility with Tomcat 9. Tomcat 9 uses Servlet 4.0 and javax.* packages, while Tomcat 10+ requires jakarta.* packages.

## Notes

- CSRF is enabled; all forms include CSRF tokens.
- Hibernate auto-generates schema (`spring.jpa.hibernate.ddl-auto=update`). For production, consider using Flyway or Liquibase.
- The consolidated report groups by vegetable name and sums quantities for the selected date.

## Next Steps / Enhancements

- Add pagination and search to lists.
- Add unit and pricing to vegetables, compute order totals.
- Export reports (CSV/PDF).
- Move admin users to DB and implement roles.
- Add validation messages i18n.

## Troubleshooting

- If you get login errors, verify `app.admin.username/password` and ensure no trailing spaces.
- If DB connection fails, ensure MySQL is running and credentials/URL are correct.
- On Windows, ensure default charset/locale doesn't break date parsing.