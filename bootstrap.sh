#!/usr/bin/env bash
set -euo pipefail

APP=order-taking

echo "Creating project structure in ./${APP}"
mkdir -p "${APP}"
cd "${APP}"

# Directories
mkdir -p src/main/java/com/example/ordertaking/config
mkdir -p src/main/java/com/example/ordertaking/controller
mkdir -p src/main/java/com/example/ordertaking/dto
mkdir -p src/main/java/com/example/ordertaking/entity
mkdir -p src/main/java/com/example/ordertaking/repository
mkdir -p src/main/resources/templates/fragments
mkdir -p src/main/resources/templates/customers
mkdir -p src/main/resources/templates/vegetables
mkdir -p src/main/resources/templates/orders
mkdir -p src/main/resources/static/css
mkdir -p src/main/resources/static/js

cat > pom.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.3</version>
    <relativePath/>
  </parent>

  <groupId>com.example</groupId>
  <artifactId>order-taking</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <name>order-taking</name>
  <description>Order Taking Application</description>

  <properties>
    <java.version>17</java.version>
  </properties>

  <dependencies>
    <!-- Web + Thymeleaf + Security + JPA + Validation -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-thymeleaf</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-security</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>

    <!-- MySQL -->
    <dependency>
      <groupId>com.mysql</groupId>
      <artifactId>mysql-connector-j</artifactId>
      <scope>runtime</scope>
    </dependency>

    <!-- Thymeleaf extras for security (optional, not required for this basic setup) -->
    <dependency>
      <groupId>org.thymeleaf.extras</groupId>
      <artifactId>thymeleaf-extras-springsecurity6</artifactId>
    </dependency>

    <!-- Test -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
          <excludes>
            <exclude>
              <groupId>org.projectlombok</groupId>
              <artifactId>lombok</artifactId>
            </exclude>
          </excludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
EOF

mkdir -p src/main/resources
cat > src/main/resources/application.yml <<'EOF'
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/order_taking?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
    username: root
    password: root
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  thymeleaf:
    cache: false

server:
  port: 8080

app:
  admin:
    username: admin
    # For demo only; prefer environment variables in production.
    password: admin123
EOF

cat > src/main/java/com/example/ordertaking/OrderTakingApplication.java <<'EOF'
package com.example.ordertaking;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class OrderTakingApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderTakingApplication.class, args);
    }
}
EOF

cat > src/main/java/com/example/ordertaking/config/SecurityConfig.java <<'EOF'
package com.example.ordertaking.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${app.admin.username}")
    private String adminUsername;

    @Value("${app.admin.password}")
    private String adminPassword;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(registry -> registry
                .requestMatchers("/css/**", "/js/**", "/images/**", "/webjars/**", "/login").permitAll()
                .anyRequest().authenticated()
            )
            .formLogin(login -> login
                .loginPage("/login")
                .defaultSuccessUrl("/customers", true)
                .permitAll()
            )
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .permitAll()
            )
            .csrf(Customizer.withDefaults());

        return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService(PasswordEncoder encoder) {
        var admin = User.withUsername(adminUsername)
                .password(encoder.encode(adminPassword))
                .roles("ADMIN")
                .build();
        return new InMemoryUserDetailsManager(admin);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
EOF

cat > src/main/java/com/example/ordertaking/controller/AuthController.java <<'EOF'
package com.example.ordertaking.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AuthController {
    @GetMapping("/login")
    public String login() {
        return "login";
    }
}
EOF

cat > src/main/java/com/example/ordertaking/controller/HomeController.java <<'EOF'
package com.example.ordertaking.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    @GetMapping("/")
    public String home() {
        return "redirect:/customers";
    }
}
EOF

cat > src/main/java/com/example/ordertaking/entity/Customer.java <<'EOF'
package com.example.ordertaking.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;

@Entity
@Table(name = "customers")
public class Customer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "First name is required")
    @Column(nullable = false)
    private String firstName;

    @NotBlank(message = "Last name is required")
    @Column(nullable = false)
    private String lastName;

    @Email
    @NotBlank(message = "Email is required")
    @Column(nullable = false, unique = true)
    private String email;

    @NotBlank(message = "Address is required")
    @Column(nullable = false, length = 1000)
    private String address;

    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public Customer() {}

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFirstName() {return firstName;}
    public void setFirstName(String firstName) {this.firstName = firstName;}

    public String getLastName() {return lastName;}
    public void setLastName(String lastName) {this.lastName = lastName;}

    public String getEmail() {return email;}
    public void setEmail(String email) {this.email = email;}

    public String getAddress() {return address;}
    public void setAddress(String address) {this.address = address;}

    public Instant getCreatedAt() {return createdAt;}
    public void setCreatedAt(Instant createdAt) {this.createdAt = createdAt;}
}
EOF

cat > src/main/java/com/example/ordertaking/entity/Vegetable.java <<'EOF'
package com.example.ordertaking.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "vegetables")
public class Vegetable {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Vegetable name is required")
    @Column(nullable = false, unique = true)
    private String name;

    public Vegetable() {}

    public Vegetable(String name) {
        this.name = name;
    }

    // Getters/setters
    public Long getId() {return id;}
    public void setId(Long id) {this.id = id;}
    public String getName() {return name;}
    public void setName(String name) {this.name = name;}
}
EOF

cat > src/main/java/com/example/ordertaking/entity/OrderItem.java <<'EOF'
package com.example.ordertaking.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;

@Entity
@Table(name = "order_items")
public class OrderItem {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    private Vegetable vegetable;

    @Min(1)
    @Column(nullable = false)
    private Integer quantity;

    @ManyToOne(optional = false)
    private OrderHeader order;

    public OrderItem() {}

    public OrderItem(Vegetable vegetable, Integer quantity, OrderHeader order) {
        this.vegetable = vegetable;
        this.quantity = quantity;
        this.order = order;
    }

    // Getters/setters
    public Long getId() {return id;}
    public void setId(Long id) {this.id = id;}
    public Vegetable getVegetable() {return vegetable;}
    public void setVegetable(Vegetable vegetable) {this.vegetable = vegetable;}
    public Integer getQuantity() {return quantity;}
    public void setQuantity(Integer quantity) {this.quantity = quantity;}
    public OrderHeader getOrder() {return order;}
    public void setOrder(OrderHeader order) {this.order = order;}
}
EOF

cat > src/main/java/com/example/ordertaking/entity/OrderHeader.java <<'EOF'
package com.example.ordertaking.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
public class OrderHeader {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne(optional = false)
    private Customer customer;

    @NotNull
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    @Column(nullable = false)
    private LocalDate orderDate;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    public OrderHeader() {}

    public OrderHeader(Customer customer, LocalDate orderDate) {
        this.customer = customer;
        this.orderDate = orderDate;
    }

    public void addItem(OrderItem item) {
        item.setOrder(this);
        items.add(item);
    }

    // Getters/setters
    public Long getId() {return id;}
    public void setId(Long id) {this.id = id;}
    public Customer getCustomer() {return customer;}
    public void setCustomer(Customer customer) {this.customer = customer;}
    public LocalDate getOrderDate() {return orderDate;}
    public void setOrderDate(LocalDate orderDate) {this.orderDate = orderDate;}
    public List<OrderItem> getItems() {return items;}
    public void setItems(List<OrderItem> items) {this.items = items;}
}
EOF

cat > src/main/java/com/example/ordertaking/dto/VegetableSummary.java <<'EOF'
package com.example.ordertaking.dto;

public class VegetableSummary {
    private String vegetableName;
    private Long totalQuantity;

    public VegetableSummary(String vegetableName, Long totalQuantity) {
        this.vegetableName = vegetableName;
        this.totalQuantity = totalQuantity;
    }

    public String getVegetableName() {return vegetableName;}
    public Long getTotalQuantity() {return totalQuantity;}
}
EOF

cat > src/main/java/com/example/ordertaking/repository/CustomerRepository.java <<'EOF'
package com.example.ordertaking.repository;

import com.example.ordertaking.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Long> {
    boolean existsByEmail(String email);
}
EOF

cat > src/main/java/com/example/ordertaking/repository/VegetableRepository.java <<'EOF'
package com.example.ordertaking.repository;

import com.example.ordertaking.entity.Vegetable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VegetableRepository extends JpaRepository<Vegetable, Long> {
    boolean existsByNameIgnoreCase(String name);
}
EOF

cat > src/main/java/com/example/ordertaking/repository/OrderRepository.java <<'EOF'
package com.example.ordertaking.repository;

import com.example.ordertaking.entity.OrderHeader;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface OrderRepository extends JpaRepository<OrderHeader, Long> {
    List<OrderHeader> findByOrderDate(LocalDate date);
}
EOF

cat > src/main/java/com/example/ordertaking/repository/OrderItemRepository.java <<'EOF'
package com.example.ordertaking.repository;

import com.example.ordertaking.dto.VegetableSummary;
import com.example.ordertaking.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    @Query("""
           select new com.example.ordertaking.dto.VegetableSummary(v.name, sum(oi.quantity))
           from OrderItem oi
             join oi.order o
             join oi.vegetable v
           where o.orderDate = :date
           group by v.name
           order by v.name asc
           """)
    List<VegetableSummary> summarizeByDate(LocalDate date);
}
EOF

cat > src/main/java/com/example/ordertaking/controller/CustomerController.java <<'EOF'
package com.example.ordertaking.controller;

import com.example.ordertaking.entity.Customer;
import com.example.ordertaking.repository.CustomerRepository;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/customers")
public class CustomerController {
    private final CustomerRepository customerRepo;

    public CustomerController(CustomerRepository customerRepo) {
        this.customerRepo = customerRepo;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("customers", customerRepo.findAll());
        model.addAttribute("tab", "customers");
        return "customers/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("customer", new Customer());
        model.addAttribute("tab", "customers");
        return "customers/form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute("customer") Customer customer, BindingResult result, Model model) {
        if (customerRepo.existsByEmail(customer.getEmail())) {
            result.rejectValue("email", "exists", "Email already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "customers");
            return "customers/form";
        }
        customerRepo.save(customer);
        return "redirect:/customers";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        var customer = customerRepo.findById(id).orElseThrow();
        model.addAttribute("customer", customer);
        model.addAttribute("tab", "customers");
        return "customers/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id, @Valid @ModelAttribute("customer") Customer customer, BindingResult result, Model model) {
        var existing = customerRepo.findById(id).orElseThrow();
        if (!existing.getEmail().equals(customer.getEmail()) && customerRepo.existsByEmail(customer.getEmail())) {
            result.rejectValue("email", "exists", "Email already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "customers");
            return "customers/form";
        }
        customer.setId(id);
        customerRepo.save(customer);
        return "redirect:/customers";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        customerRepo.deleteById(id);
        return "redirect:/customers";
    }
}
EOF

cat > src/main/java/com/example/ordertaking/controller/VegetableController.java <<'EOF'
package com.example.ordertaking.controller;

import com.example.ordertaking.entity.Vegetable;
import com.example.ordertaking.repository.VegetableRepository;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/vegetables")
public class VegetableController {
    private final VegetableRepository vegetableRepo;

    public VegetableController(VegetableRepository vegetableRepo) {
        this.vegetableRepo = vegetableRepo;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("vegetables", vegetableRepo.findAll());
        model.addAttribute("tab", "vegetables");
        return "vegetables/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("vegetable", new Vegetable());
        model.addAttribute("tab", "vegetables");
        return "vegetables/form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute("vegetable") Vegetable vegetable, BindingResult result, Model model) {
        if (vegetableRepo.existsByNameIgnoreCase(vegetable.getName())) {
            result.rejectValue("name", "exists", "Vegetable already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "vegetables");
            return "vegetables/form";
        }
        vegetableRepo.save(vegetable);
        return "redirect:/vegetables";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        var veg = vegetableRepo.findById(id).orElseThrow();
        model.addAttribute("vegetable", veg);
        model.addAttribute("tab", "vegetables");
        return "vegetables/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id, @Valid @ModelAttribute("vegetable") Vegetable vegetable, BindingResult result, Model model) {
        var existing = vegetableRepo.findById(id).orElseThrow();
        if (!existing.getName().equalsIgnoreCase(vegetable.getName())
                && vegetableRepo.existsByNameIgnoreCase(vegetable.getName())) {
            result.rejectValue("name", "exists", "Vegetable already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "vegetables");
            return "vegetables/form";
        }
        vegetable.setId(id);
        vegetableRepo.save(vegetable);
        return "redirect:/vegetables";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        vegetableRepo.deleteById(id);
        return "redirect:/vegetables";
    }
}
EOF

cat > src/main/java/com/example/ordertaking/controller/OrderController.java <<'EOF'
package com.example.ordertaking.controller;

import com.example.ordertaking.dto.VegetableSummary;
import com.example.ordertaking.entity.OrderHeader;
import com.example.ordertaking.entity.OrderItem;
import com.example.ordertaking.repository.CustomerRepository;
import com.example.ordertaking.repository.OrderItemRepository;
import com.example.ordertaking.repository.OrderRepository;
import com.example.ordertaking.repository.VegetableRepository;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/orders")
public class OrderController {

    private final CustomerRepository customerRepo;
    private final VegetableRepository vegetableRepo;
    private final OrderRepository orderRepo;
    private final OrderItemRepository orderItemRepo;

    public OrderController(CustomerRepository customerRepo,
                           VegetableRepository vegetableRepo,
                           OrderRepository orderRepo,
                           OrderItemRepository orderItemRepo) {
        this.customerRepo = customerRepo;
        this.vegetableRepo = vegetableRepo;
        this.orderRepo = orderRepo;
        this.orderItemRepo = orderItemRepo;
    }

    @GetMapping("/new")
    public String newOrder(Model model) {
        model.addAttribute("customers", customerRepo.findAll());
        model.addAttribute("vegetables", vegetableRepo.findAll());
        model.addAttribute("today", LocalDate.now());
        model.addAttribute("tab", "ordertaking");
        return "orders/new";
    }

    @PostMapping
    public String createOrder(
            @RequestParam("customerId") Long customerId,
            @RequestParam("orderDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate orderDate,
            @RequestParam("vegetableIds") List<Long> vegetableIds,
            @RequestParam("quantities") List<Integer> quantities,
            Model model
    ) {
        if (vegetableIds == null || quantities == null || vegetableIds.isEmpty() || quantities.isEmpty() || vegetableIds.size() != quantities.size()) {
            model.addAttribute("error", "Please add at least one vegetable with quantity.");
            return "redirect:/orders/new";
        }

        var customer = customerRepo.findById(customerId).orElseThrow();
        var order = new OrderHeader(customer, orderDate);

        List<OrderItem> items = new ArrayList<>();
        for (int i = 0; i < vegetableIds.size(); i++) {
            var vegId = vegetableIds.get(i);
            var qty = quantities.get(i);
            if (qty == null || qty <= 0) continue;
            var veg = vegetableRepo.findById(vegId).orElseThrow();
            var item = new OrderItem(veg, qty, order);
            items.add(item);
            order.addItem(item);
        }

        if (order.getItems().isEmpty()) {
            model.addAttribute("error", "Please provide valid quantities.");
            return "redirect:/orders/new";
        }

        orderRepo.save(order);
        return "redirect:/orders/" + order.getId();
    }

    @GetMapping("/{id}")
    public String orderDetails(@PathVariable Long id, Model model) {
        var order = orderRepo.findById(id).orElseThrow();
        model.addAttribute("order", order);
        model.addAttribute("tab", "ordertaking");
        return "orders/confirm";
    }

    @GetMapping("/final")
    public String finalOrders(
            @RequestParam(value = "date", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model
    ) {
        if (date == null) {
            date = LocalDate.now();
        }
        List<VegetableSummary> summary = orderItemRepo.summarizeByDate(date);
        model.addAttribute("date", date);
        model.addAttribute("summary", summary);
        model.addAttribute("orders", orderRepo.findByOrderDate(date));
        model.addAttribute("tab", "finalorders");
        return "orders/final";
    }
}
EOF

cat > src/main/resources/templates/fragments/nav.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<body>
<nav style="display:flex; gap:16px; align-items:center; padding:10px; background:#f5f5f5; border-bottom:1px solid #ddd;">
  <a th:href="@{/customers}" th:classappend="${tab}=='customers' ? 'active' : ''">Customers</a>
  <a th:href="@{/vegetables}" th:classappend="${tab}=='vegetables' ? 'active' : ''">Vegetables</a>
  <a th:href="@{/orders/new}" th:classappend="${tab}=='ordertaking' ? 'active' : ''">Order Taking</a>
  <a th:href="@{/orders/final}" th:classappend="${tab}=='finalorders' ? 'active' : ''">Final Orders</a>
  <div style="margin-left:auto;">
    <form th:action="@{/logout}" method="post" style="display:inline;">
      <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}" />
      <button type="submit">Logout</button>
    </form>
  </div>
</nav>
</body>
</html>
EOF

cat > src/main/resources/templates/login.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Login</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
</head>
<body>
<div class="container small">
  <h2>Admin Login</h2>
  <form th:action="@{/login}" method="post">
    <div class="form-group">
      <label for="username">Username</label>
      <input id="username" name="username" type="text" required />
    </div>
    <div class="form-group">
      <label for="password">Password</label>
      <input id="password" name="password" type="password" required />
    </div>
    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}" />
    <button type="submit">Sign in</button>
    <div th:if="${param.error}" class="error">Invalid username or password.</div>
    <div th:if="${param.logout}" class="success">You have been logged out.</div>
  </form>
</div>
</body>
</html>
EOF

cat > src/main/resources/templates/customers/list.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Customers</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <div class="toolbar">
    <h2>Customers</h2>
    <a class="btn" th:href="@{/customers/new}">Add Customer</a>
  </div>
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>First</th>
      <th>Last</th>
      <th>Email</th>
      <th>Address</th>
      <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr th:each="c, iter : ${customers}">
      <td th:text="${iter.count}">1</td>
      <td th:text="${c.firstName}">John</td>
      <td th:text="${c.lastName}">Doe</td>
      <td th:text="${c.email}">j@d.com</td>
      <td th:text="${c.address}">Somewhere</td>
      <td>
        <a th:href="@{|/customers/${c.id}/edit|}">Edit</a>
        <form th:action="@{|/customers/${c.id}/delete|}" method="post" style="display:inline;">
          <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}" />
          <button type="submit" class="link danger" onclick="return confirm('Delete this customer?')">Delete</button>
        </form>
      </td>
    </tr>
    </tbody>
  </table>
</div>
</body>
</html>
EOF

cat > src/main/resources/templates/customers/form.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title th:text="${customer.id} != null ? 'Edit Customer' : 'Add Customer'">Customer</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <h2 th:text="${customer.id} != null ? 'Edit Customer' : 'Add Customer'">Customer</h2>
  <form th:action="${customer.id} != null ? @{|/customers/${customer.id}/edit|} : @{/customers}" th:object="${customer}" method="post">
    <div class="form-group">
      <label>First Name</label>
      <input th:field="*{firstName}" type="text" required />
      <div class="error" th:if="${#fields.hasErrors('firstName')}" th:errors="*{firstName}">First name error</div>
    </div>
    <div class="form-group">
      <label>Last Name</label>
      <input th:field="*{lastName}" type="text" required />
      <div class="error" th:if="${#fields.hasErrors('lastName')}" th:errors="*{lastName}">Last name error</div>
    </div>
    <div class="form-group">
      <label>Email</label>
      <input th:field="*{email}" type="email" required />
      <div class="error" th:if="${#fields.hasErrors('email')}" th:errors="*{email}">Email error</div>
    </div>
    <div class="form-group">
      <label>Address</label>
      <textarea th:field="*{address}" rows="3" required></textarea>
      <div class="error" th:if="${#fields.hasErrors('address')}" th:errors="*{address}">Address error</div>
    </div>
    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}" />
    <div class="toolbar">
      <button type="submit" class="btn">Save</button>
      <a th:href="@{/customers}" class="btn secondary">Cancel</a>
    </div>
  </form>
</div>
</body>
</html>
EOF

cat > src/main/resources/templates/vegetables/list.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Vegetables</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <div class="toolbar">
    <h2>Vegetables</h2>
    <a class="btn" th:href="@{/vegetables/new}">Add Vegetable</a>
  </div>
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>Name</th>
      <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr th:each="v, iter : ${vegetables}">
      <td th:text="${iter.count}">1</td>
      <td th:text="${v.name}">Tomato</td>
      <td>
        <a th:href="@{|/vegetables/${v.id}/edit|}">Edit</a>
        <form th:action="@{|/vegetables/${v.id}/delete|}" method="post" style="display:inline;">
          <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}" />
          <button type="submit" class="link danger" onclick="return confirm('Delete this vegetable?')">Delete</button>
        </form>
      </td>
    </tr>
    </tbody>
  </table>
</div>
</body>
</html>
EOF

cat > src/main/resources/templates/vegetables/form.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title th:text="${vegetable.id} != null ? 'Edit Vegetable' : 'Add Vegetable'">Vegetable</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <h2 th:text="${vegetable.id} != null ? 'Edit Vegetable' : 'Add Vegetable'">Vegetable</h2>
  <form th:action="${vegetable.id} != null ? @{|/vegetables/${vegetable.id}/edit|} : @{/vegetables}" th:object="${vegetable}" method="post">
    <div class="form-group">
      <label>Name</label>
      <input th:field="*{name}" type="text" required />
      <div class="error" th:if="${#fields.hasErrors('name')}" th:errors="*{name}">Name error</div>
    </div>
    <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}" />
    <div class="toolbar">
      <button type="submit" class="btn">Save</button>
      <a th:href="@{/vegetables}" class="btn secondary">Cancel</a>
    </div>
  </form>
</div>
</body>
</html>
EOF

cat > src/main/resources/templates/orders/new.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Taking</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <h2>Order Taking</h2>
  <form th:action="@{/orders}" method="post" id="orderForm">
    <div class="form-columns">
      <div class="form-group">
        <label>Customer</label>
        <select name="customerId" required>
          <option value="" disabled selected>Select a customer</option>
          <option th:each="c : ${customers}" th:value="${c.id}" th:text="${c.firstName + ' ' + c.lastName + ' (' + c.email + ')'}"></option>
        </select>
      </div>
      <div class="form-group">
        <label>Date</label>
        <input type="date" name="orderDate" th:value="${today}" required />
      </div>
    </div>

    <h3>Items</h3>
    <table id="itemsTable">
      <thead>
      <tr>
        <th>Vegetable</th>
        <th>Quantity</th>
        <th></th>
      </tr>
      </thead>
      <tbody id="itemsBody">
      <tr>
        <td>
          <select name="vegetableIds" required>
            <option value="" disabled selected>Select</option>
            <option th:each="v : ${vegetables}" th:value="${v.id}" th:text="${v.name}"></option>
          </select>
        </td>
        <td>
          <input name="quantities" type="number" min="1" value="1" required />
        </td>
        <td>
          <button type="button" class="link danger" onclick="removeRow(this)">Remove</button>
        </td>
      </tr>
      </tbody>
    </table>

    <div class="toolbar">
      <button type="button" class="btn secondary" onclick="addRow()">Add Item</button>
      <span style="flex:1"></span>
      <input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}" />
      <button type="submit" class="btn">Submit Order</button>
    </div>
  </form>
</div>
<script th:src="@{/js/orders.js}"></script>
</body>
</html>
EOF

cat > src/main/resources/templates/orders/confirm.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Confirmation</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
  <style>
    @media print {
      nav, .toolbar, .print-btn { display: none !important; }
      .container { box-shadow: none; }
    }
  </style>
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <div class="toolbar">
    <h2>Order Confirmation</h2>
    <button class="btn print-btn" onclick="window.print()">Print</button>
  </div>
  <div>
    <p><strong>Order ID:</strong> <span th:text="${order.id}"></span></p>
    <p><strong>Date:</strong> <span th:text="${order.orderDate}"></span></p>
    <p><strong>Customer:</strong> <span th:text="${order.customer.firstName + ' ' + order.customer.lastName}"></span> (<span th:text="${order.customer.email}"></span>)</p>
    <p><strong>Address:</strong> <span th:text="${order.customer.address}"></span></p>
  </div>
  <h3>Items</h3>
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>Vegetable</th>
      <th>Quantity</th>
    </tr>
    </thead>
    <tbody>
    <tr th:each="item, iter : ${order.items}">
      <td th:text="${iter.count}">1</td>
      <td th:text="${item.vegetable.name}">Tomato</td>
      <td th:text="${item.quantity}">1</td>
    </tr>
    </tbody>
  </table>
  <div class="toolbar">
    <a class="btn secondary" th:href="@{/orders/new}">New Order</a>
    <a class="btn" th:href="@{/orders/final(date=${order.orderDate})}">View Final Orders (Same Date)</a>
  </div>
</div>
</body>
</html>
EOF

cat > src/main/resources/templates/orders/final.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Final Orders</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <div class="toolbar">
    <h2>Final Orders</h2>
    <form method="get" th:action="@{/orders/final}" style="display:flex; gap:8px; align-items:center;">
      <label for="date">Date</label>
      <input id="date" type="date" name="date" th:value="${date}" />
      <button type="submit" class="btn">Apply</button>
      <button type="button" class="btn secondary" onclick="window.print()">Print</button>
    </form>
  </div>

  <h3>Consolidated Summary (Date: <span th:text="${date}"></span>)</h3>
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>Vegetable</th>
      <th>Total Quantity</th>
    </tr>
    </thead>
    <tbody>
    <tr th:if="${#lists.isEmpty(summary)}">
      <td colspan="3">No orders found for the selected date.</td>
    </tr>
    <tr th:each="s, iter : ${summary}">
      <td th:text="${iter.count}">1</td>
      <td th:text="${s.vegetableName}">Tomato</td>
      <td th:text="${s.totalQuantity}">10</td>
    </tr>
    </tbody>
  </table>

  <h3 style="margin-top:24px;">Orders List</h3>
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>Order ID</th>
      <th>Customer</th>
      <th>Items</th>
    </tr>
    </thead>
    <tbody>
    <tr th:if="${#lists.isEmpty(orders)}">
      <td colspan="4">No orders.</td>
    </tr>
    <tr th:each="o, iter : ${orders}">
      <td th:text="${iter.count}">1</td>
      <td><a th:href="@{|/orders/${o.id}|}" th:text="${o.id}">1</a></td>
      <td th:text="${o.customer.firstName + ' ' + o.customer.lastName}">John Doe</td>
      <td>
        <ul style="margin:0; padding-left:18px;">
          <li th:each="it : ${o.items}" th:text="${it.vegetable.name + ' x ' + it.quantity}">Tomato x 1</li>
        </ul>
      </td>
    </tr>
    </tbody>
  </table>
</div>
</body>
</html>
EOF

cat > src/main/resources/static/css/styles.css <<'EOF'
:root {
  --primary: #2c7be5;
  --secondary: #6c757d;
  --danger: #dc3545;
  --border: #ddd;
}

* { box-sizing: border-box; }
body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 0; background: #fafafa; }

.container { max-width: 1000px; margin: 24px auto; background: white; padding: 16px; border: 1px solid var(--border); border-radius: 8px; }
.container.small { max-width: 420px; }

.toolbar { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.toolbar h2 { margin: 0; }

.form-group { display: flex; flex-direction: column; gap: 6px; margin-bottom: 12px; }
.form-columns { display: flex; gap: 16px; flex-wrap: wrap; }
label { font-weight: 600; }
input[type="text"], input[type="email"], input[type="password"], input[type="date"], input[type="number"], select, textarea {
  padding: 8px; border: 1px solid var(--border); border-radius: 6px; width: 100%;
}
textarea { resize: vertical; }

.btn { background: var(--primary); color: white; border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; text-decoration: none; display: inline-block; }
.btn.secondary { background: var(--secondary); }
.link { border: none; background: none; color: var(--primary); cursor: pointer; }
.link.danger { color: var(--danger); }
.error { color: var(--danger); font-size: 0.9em; }
.success { color: green; }

table { width: 100%; border-collapse: collapse; }
th, td { border-bottom: 1px solid var(--border); padding: 8px; text-align: left; }
th { background: #f5f5f5; }

nav a { text-decoration: none; color: #333; padding: 6px 10px; border-radius: 6px; }
nav a.active { background: var(--primary); color: #fff; }
EOF

cat > src/main/resources/static/js/orders.js <<'EOF'
function addRow() {
  const tbody = document.getElementById('itemsBody');
  const row = document.createElement('tr');
  row.innerHTML = `
    <td>
      <select name="vegetableIds" required>
        ${document.querySelector('#itemsBody select[name="vegetableIds"]').innerHTML}
      </select>
    </td>
    <td>
      <input name="quantities" type="number" min="1" value="1" required />
    </td>
    <td>
      <button type="button" class="link danger" onclick="removeRow(this)">Remove</button>
    </td>
  `;
  const sel = row.querySelector('select[name="vegetableIds"]');
  if (sel.options.length > 0) sel.selectedIndex = 0;
  tbody.appendChild(row);
}

function removeRow(btn) {
  const tr = btn.closest('tr');
  const tbody = tr.parentElement;
  if (tbody.children.length > 1) {
    tbody.removeChild(tr);
  } else {
    tr.querySelector('select[name="vegetableIds"]').selectedIndex = 0;
    tr.querySelector('input[name="quantities"]').value = 1;
  }
}
EOF

cat > src/main/resources/templates/orders/confirm.html <<'EOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="en">
<head>
  <meta charset="UTF-8">
  <title>Order Confirmation</title>
  <link rel="stylesheet" th:href="@{/css/styles.css}" />
  <style>
    @media print {
      nav, .toolbar, .print-btn { display: none !important; }
      .container { box-shadow: none; }
    }
  </style>
</head>
<body>
<div th:replace="~{fragments/nav :: body}"></div>
<div class="container">
  <div class="toolbar">
    <h2>Order Confirmation</h2>
    <button class="btn print-btn" onclick="window.print()">Print</button>
  </div>
  <div>
    <p><strong>Order ID:</strong> <span th:text="${order.id}"></span></p>
    <p><strong>Date:</strong> <span th:text="${order.orderDate}"></span></p>
    <p><strong>Customer:</strong> <span th:text="${order.customer.firstName + ' ' + order.customer.lastName}"></span> (<span th:text="${order.customer.email}"></span>)</p>
    <p><strong>Address:</strong> <span th:text="${order.customer.address}"></span></p>
  </div>
  <h3>Items</h3>
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>Vegetable</th>
      <th>Quantity</th>
    </tr>
    </thead>
    <tbody>
    <tr th:each="item, iter : ${order.items}">
      <td th:text="${iter.count}">1</td>
      <td th:text="${item.vegetable.name}">Tomato</td>
      <td th:text="${item.quantity}">1</td>
    </tr>
    </tbody>
  </table>
  <div class="toolbar">
    <a class="btn secondary" th:href="@{/orders/new}">New Order</a>
    <a class="btn" th:href="@{/orders/final(date=${order.orderDate})}">View Final Orders (Same Date)</a>
  </div>
</div>
</body>
</html>
EOF

cat > README.md <<'EOF'
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