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