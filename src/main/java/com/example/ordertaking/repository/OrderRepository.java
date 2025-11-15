package com.example.ordertaking.repository;

import com.example.ordertaking.entity.OrderHeader;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface OrderRepository extends JpaRepository<OrderHeader, Long> {
    List<OrderHeader> findByOrderDate(LocalDate date);
}