package com.poswarungbakso.model;

public class Product {
    private int id;
    private String code;
    private String name;
    private int price;
    private int stock;

    // Constructor, getter, setter
    public Product() {}
    public Product(int id, String code, String name, int price, int stock) {
        this.id = id; this.code = code; this.name = name;
        this.price = price; this.stock = stock;
    }

    // Getter & Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
}