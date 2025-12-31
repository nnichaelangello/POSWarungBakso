package com.poswarungbakso.dao;

import com.poswarungbakso.model.Product;
import com.poswarungbakso.model.Transaction;
import com.poswarungbakso.model.TransactionItem;
import com.poswarungbakso.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    private ProductDAO productDAO = new ProductDAO();

    // Simpan transaksi lengkap (header + items) + kurangi stok
        public boolean saveTransaction(Transaction transaction, String cashier) {
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Mulai transaksi

            // 1. Insert header transaksi
            String sqlHeader = "INSERT INTO transactions (transaction_code, date, cashier, total) VALUES (?, ?, ?, ?)";
            PreparedStatement pstHeader = conn.prepareStatement(sqlHeader, Statement.RETURN_GENERATED_KEYS);
            pstHeader.setString(1, transaction.getTransactionCode());
            pstHeader.setLong(2, transaction.getDate());
            pstHeader.setString(3, cashier);
            pstHeader.setInt(4, transaction.getTotal());

            int headerRows = pstHeader.executeUpdate();
            if (headerRows == 0) {
                conn.rollback();
                System.err.println("Gagal insert header transaksi");
                return false;
            }

            // Ambil ID transaksi yang baru dibuat
            ResultSet generatedKeys = pstHeader.getGeneratedKeys();
            if (!generatedKeys.next()) {
                conn.rollback();
                System.err.println("Gagal ambil generated ID transaksi");
                return false;
            }
            int transactionId = generatedKeys.getInt(1);

            // 2. Insert semua items + simpan perubahan stok sementara
            String sqlItem = "INSERT INTO transaction_items (transaction_id, product_code, product_name, quantity, price, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement pstItem = conn.prepareStatement(sqlItem);

            List<String> updatedProducts = new ArrayList<>(); // untuk rollback stok jika gagal
            List<Integer> oldStocks = new ArrayList<>();

            for (TransactionItem item : transaction.getItems()) {
                Product p = productDAO.getProductByCode(item.getProductCode());
                if (p == null || p.getStock() < item.getQuantity()) {
                    conn.rollback();
                    System.err.println("Stok tidak cukup untuk " + item.getProductCode());
                    return false;
                }

                // Simpan stok lama untuk rollback jika gagal
                updatedProducts.add(item.getProductCode());
                oldStocks.add(p.getStock());

                // Kurangi stok (masih dalam transaksi, bisa rollback)
                boolean stockUpdated = productDAO.updateStock(item.getProductCode(), p.getStock() - item.getQuantity());
                if (!stockUpdated) {
                    conn.rollback();
                    System.err.println("Gagal update stok untuk " + item.getProductCode());
                    return false;
                }

                // Insert item
                pstItem.setInt(1, transactionId);
                pstItem.setString(2, item.getProductCode());
                pstItem.setString(3, item.getProductName());
                pstItem.setInt(4, item.getQuantity());
                pstItem.setInt(5, item.getPrice());
                pstItem.setInt(6, item.getSubtotal());
                pstItem.addBatch();
            }

            // Execute batch insert items
            int[] itemResults = pstItem.executeBatch();
            boolean itemsSuccess = true;
            for (int result : itemResults) {
                if (result < 0 && result != Statement.SUCCESS_NO_INFO) {
                    itemsSuccess = false;
                    break;
                }
            }

            if (!itemsSuccess) {
                conn.rollback();
                System.err.println("Gagal insert batch items");
                return false;
            }

            // SEMUA BERHASIL → COMMIT
            conn.commit();
            System.out.println("Transaksi berhasil disimpan: " + transaction.getTransactionCode());
            return true;

        } catch (SQLException e) {
            System.err.println("Error transaksi: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                    System.err.println("Transaksi dibatalkan (rollback)");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // Ambil transaksi hari ini untuk statistik & riwayat
    public List<Transaction> getTodayTransactions() {
        List<Transaction> list = new ArrayList<>();
        long todayStart = System.currentTimeMillis() - (System.currentTimeMillis() % 86400000); // midnight
        String sql = "SELECT * FROM transactions WHERE date >= ? ORDER BY date DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setLong(1, todayStart);
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

    protected List<TransactionItem> getItemsByTransactionId(int transactionId) {
        List<TransactionItem> items = new ArrayList<>();
        String sql = "SELECT * FROM transaction_items WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setInt(1, transactionId);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) {
                TransactionItem item = new TransactionItem();
                item.setProductCode(rs.getString("product_code"));
                item.setProductName(rs.getString("product_name"));
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

    // Statistik hari ini
    public int getTodayTransactionCount() {
        return getTodayTransactions().size();
    }

    public int getTodayRevenue() {
        return getTodayTransactions().stream().mapToInt(Transaction::getTotal).sum();
    }
}