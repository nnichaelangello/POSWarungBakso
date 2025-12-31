package com.poswarungbakso.dao;

import com.poswarungbakso.model.Transaction;
import com.poswarungbakso.model.TransactionItem;
import com.poswarungbakso.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO extends TransactionDAO { // extend agar bisa pakai method getToday dll jika perlu

    // Ambil transaksi berdasarkan rentang tanggal (start & end dalam millis)
    public List<Transaction> getTransactionsByRange(long startDate, long endDate) {
        List<Transaction> list = new ArrayList<>();
        String sql = "SELECT * FROM transactions WHERE date BETWEEN ? AND ? ORDER BY date DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setLong(1, startDate);
            pst.setLong(2, endDate);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setTransactionCode(rs.getString("transaction_code"));
                t.setDate(rs.getLong("date"));
                t.setCashier(rs.getString("cashier"));
                t.setTotal(rs.getInt("total"));
                t.setItems(getItemsByTransactionId(rs.getInt("id")));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Summary laporan
    public int getTotalTransactions(long start, long end) {
        return getTransactionsByRange(start, end).size();
    }

    public int getTotalRevenue(long start, long end) {
        return getTransactionsByRange(start, end).stream().mapToInt(Transaction::getTotal).sum();
    }

    public double getAverageTransaction(long start, long end) {
        List<Transaction> trans = getTransactionsByRange(start, end);
        if (trans.isEmpty()) return 0;
        return (double) getTotalRevenue(start, end) / trans.size();
    }

    // Produk terlaris dalam range
    public String getTopProduct(long start, long end) {
        String sql = "SELECT product_name, SUM(quantity) as total_qty " +
                     "FROM transaction_items ti " +
                     "JOIN transactions t ON ti.transaction_id = t.id " +
                     "WHERE t.date BETWEEN ? AND ? " +
                     "GROUP BY product_name " +
                     "ORDER BY total_qty DESC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setLong(1, start);
            pst.setLong(2, end);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                return rs.getString("product_name") + " (" + rs.getInt("total_qty") + "x)";
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "-";
    }
}