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

- Java 17, Spring Boot 3
- Spring MVC, Spring Data JPA (Hibernate), Spring Security
- Thymeleaf, HTML/CSS/JS
- MySQL

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
5. Open http://localhost:8080 and log in with your admin credentials.

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