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