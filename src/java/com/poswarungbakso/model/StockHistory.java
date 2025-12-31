package com.poswarungbakso.model;

public class StockHistory {
    private String productCode;
    private String productName;
    private int quantity;
    private String reason;
    private int afterStock;
    private long timestamp;

    public StockHistory() {}

    public String getProductCode() { return productCode; }
    public void setProductCode(String productCode) { this.productCode = productCode; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public int getAfterStock() { return afterStock; }
    public void setAfterStock(int afterStock) { this.afterStock = afterStock; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
}