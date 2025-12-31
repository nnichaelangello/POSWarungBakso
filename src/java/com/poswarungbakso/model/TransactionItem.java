package com.poswarungbakso.model;

public class TransactionItem {
    private int id;
    private int transactionId;
    private String productCode;
    private int quantity;
    private int price;
    private int subtotal;
    private String productName; 

    // Constructor, getter, setter semua seperti biasa
    public TransactionItem() {}
    // ... getter setter untuk id, transactionId, productCode, quantity, price, subtotal
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }
    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public int getSubtotal() { return subtotal; }
    public void setSubtotal(int subtotal) { this.subtotal = subtotal; }
}