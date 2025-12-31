package com.poswarungbakso.model;

import java.util.List;

public class Transaction {
    private int id;
    private String transactionCode;
    private long date; // millis
    private String cashier;
    private int total;
    private List<TransactionItem> items;

    // Constructor kosong + full
    public Transaction() {}

    // Getter & Setter semua
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTransactionCode() { return transactionCode; }
    public void setTransactionCode(String transactionCode) { this.transactionCode = transactionCode; }
    public long getDate() { return date; }
    public void setDate(long date) { this.date = date; }
    public String getCashier() { return cashier; }
    public void setCashier(String cashier) { this.cashier = cashier; }
    public int getTotal() { return total; }
    public void setTotal(int total) { this.total = total; }
    public List<TransactionItem> getItems() { return items; }
    public void setItems(List<TransactionItem> items) { this.items = items; }
}