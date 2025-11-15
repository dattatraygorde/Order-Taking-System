package com.example.ordertaking.repository;

import com.example.ordertaking.entity.Customer;
import com.example.ordertaking.entity.OrderHeader;
import com.example.ordertaking.entity.OrderItem;
import com.example.ordertaking.entity.Vegetable;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class OrderItemRepositoryTest {

    @Autowired private CustomerRepository customerRepository;
    @Autowired private VegetableRepository vegetableRepository;
    @Autowired private OrderRepository orderRepository;
    @Autowired private OrderItemRepository orderItemRepository;

    @Test
    void summarizeByDate_shouldSumQuantitiesPerVegetable() {
        // Arrange
        Customer c = new Customer();
        c.setFirstName("Test");
        c.setLastName("User");
        c.setEmail("test.user@example.com");
        c.setAddress("X Street");
        c = customerRepository.save(c);

        Vegetable tomato = vegetableRepository.save(new Vegetable("Tomato"));
        Vegetable onion = vegetableRepository.save(new Vegetable("Onion"));

        LocalDate date = LocalDate.of(2025, 1, 1);
        OrderHeader o1 = new OrderHeader(c, date);
        o1.addItem(new OrderItem(tomato, 2, o1));
        o1.addItem(new OrderItem(onion, 3, o1));
        orderRepository.save(o1);

        OrderHeader o2 = new OrderHeader(c, date);
        o2.addItem(new OrderItem(tomato, 5, o2));
        orderRepository.save(o2);

        // Act
        var summary = orderItemRepository.summarizeByDate(date);

        // Assert
        assertThat(summary).hasSize(2);
        var tomatoRow = summary.stream().filter(s -> s.getVegetableName().equals("Tomato")).findFirst().orElseThrow();
        var onionRow = summary.stream().filter(s -> s.getVegetableName().equals("Onion")).findFirst().orElseThrow();
        assertThat(tomatoRow.getTotalQuantity()).isEqualTo(7L);
        assertThat(onionRow.getTotalQuantity()).isEqualTo(3L);
    }
}