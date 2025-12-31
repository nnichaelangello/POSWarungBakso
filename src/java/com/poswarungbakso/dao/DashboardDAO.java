package com.poswarungbakso.dao;

import com.poswarungbakso.model.*;
import com.poswarungbakso.util.DatabaseConnection;
import java.sql.*;
import java.util.*;

public class DashboardDAO {

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setCode(rs.getString("code"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                p.setStock(rs.getInt("stock"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Transaction> getAllTransactions() {
        List<Transaction> transactions = new ArrayList<>();
        String sql = "SELECT * FROM transactions ORDER BY date DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setTransactionCode(rs.getString("transaction_code"));
                t.setDate(rs.getLong("date"));
                t.setCashier(rs.getString("cashier"));
                t.setTotal(rs.getInt("total"));
                t.setItems(getItemsByTransactionId(t.getId()));
                transactions.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return transactions;
    }

    private List<TransactionItem> getItemsByTransactionId(int transactionId) {
        List<TransactionItem> items = new ArrayList<>();
        String sql = "SELECT * FROM transaction_items WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setInt(1, transactionId);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) {
                TransactionItem item = new TransactionItem();
                item.setProductCode(rs.getString("product_code"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getInt("price"));
                item.setSubtotal(rs.getInt("subtotal"));
                items.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public List<ActivityLog> getAllActivityLogs() {
        List<ActivityLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM activity_log ORDER BY timestamp DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                ActivityLog log = new ActivityLog();
                log.setId(rs.getInt("id"));
                log.setActivity(rs.getString("activity"));
                log.setTimestamp(rs.getLong("timestamp"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
}