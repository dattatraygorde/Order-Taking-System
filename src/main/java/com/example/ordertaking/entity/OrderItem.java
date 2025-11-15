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