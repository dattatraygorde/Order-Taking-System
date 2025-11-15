package com.example.ordertaking.repository;

import com.example.ordertaking.dto.VegetableSummary;
import com.example.ordertaking.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    @Query("select new com.example.ordertaking.dto.VegetableSummary(v.name, sum(oi.quantity)) " +
           "from OrderItem oi " +
           "join oi.order o " +
           "join oi.vegetable v " +
           "where o.orderDate = :date " +
           "group by v.name " +
           "order by v.name asc")
    List<VegetableSummary> summarizeByDate(LocalDate date);
}