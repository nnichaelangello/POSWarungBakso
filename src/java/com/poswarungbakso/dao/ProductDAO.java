package com.poswarungbakso.dao;

import com.poswarungbakso.model.Product;
import com.poswarungbakso.model.StockHistory;
import com.poswarungbakso.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // Ambil semua produk
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY name";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setCode(rs.getString("code"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                p.setStock(rs.getInt("stock"));
                products.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    // Tambah produk baru
    public boolean addProduct(Product product) {
        String sql = "INSERT INTO products (code, name, price, stock) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setString(1, product.getCode());
            pst.setString(2, product.getName());
            pst.setInt(3, product.getPrice());
            pst.setInt(4, product.getStock());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update produk
    public boolean updateProduct(Product product) {
        String sql = "UPDATE products SET code = ?, name = ?, price = ?, stock = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setString(1, product.getCode());
            pst.setString(2, product.getName());
            pst.setInt(3, product.getPrice());
            pst.setInt(4, product.getStock());
            pst.setInt(5, product.getId());
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Hapus produk
    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setInt(1, id);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Cari produk berdasarkan keyword (untuk search)
    public List<Product> searchProducts(String keyword) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE code LIKE ? OR name LIKE ? ORDER BY name";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            String search = "%" + keyword + "%";
            pst.setString(1, search);
            pst.setString(2, search);
            ResultSet rs = pst.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setCode(rs.getString("code"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                p.setStock(rs.getInt("stock"));
                products.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }
    
        // Ambil produk berdasarkan code
        public Product getProductByCode(String code) {
            String sql = "SELECT * FROM products WHERE code = ?";
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, code);
                ResultSet rs = pst.executeQuery();
                if (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setCode(rs.getString("code"));
                    p.setName(rs.getString("name"));
                    p.setPrice(rs.getInt("price"));
                    p.setStock(rs.getInt("stock"));
                    return p;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return null;
        }

        // Update stok
        public boolean updateStock(String code, int newStock) {
            String sql = "UPDATE products SET stock = ? WHERE code = ?";
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setInt(1, newStock);
                pst.setString(2, code);
                return pst.executeUpdate() > 0;
            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }

    // Tambah riwayat stok
    public boolean addStockHistory(String productCode, String productName, int quantity, String reason, int afterStock, long timestamp) {
        String sql = "INSERT INTO stock_history (product_code, product_name, quantity, reason, after_stock, timestamp) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {
            pst.setString(1, productCode);
            pst.setString(2, productName);
            pst.setInt(3, quantity);
            pst.setString(4, reason);
            pst.setInt(5, afterStock);
            pst.setLong(6, timestamp);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Ambil semua riwayat stok
    public List<StockHistory> getAllStockHistory() {
        List<StockHistory> history = new ArrayList<>();
        String sql = "SELECT * FROM stock_history ORDER BY timestamp DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql);
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                StockHistory sh = new StockHistory();
                sh.setProductCode(rs.getString("product_code"));
                sh.setProductName(rs.getString("product_name"));
                sh.setQuantity(rs.getInt("quantity"));
                sh.setReason(rs.getString("reason"));
                sh.setAfterStock(rs.getInt("after_stock"));
                sh.setTimestamp(rs.getLong("timestamp"));
                history.add(sh);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }
}