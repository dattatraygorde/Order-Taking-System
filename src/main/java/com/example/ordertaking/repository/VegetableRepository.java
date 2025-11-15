package com.example.ordertaking.repository;

import com.example.ordertaking.entity.Vegetable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VegetableRepository extends JpaRepository<Vegetable, Long> {
    boolean existsByNameIgnoreCase(String name);
}