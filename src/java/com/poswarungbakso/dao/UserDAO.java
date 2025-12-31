package com.poswarungbakso.dao;

import com.poswarungbakso.model.User;
import com.poswarungbakso.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // Login user
    public User login(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setString(1, username);
            pst.setString(2, password);

            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                return user;
            }
        } catch (SQLException e) {
            System.err.println("Error login: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Cek apakah username sudah ada (untuk tambah & edit)
    public boolean isUsernameExists(String username) {
        return isUsernameExists(username, 0);
    }

    public boolean isUsernameExists(String username, int excludeId) {
        String sql = "SELECT id FROM users WHERE username = ? AND id != ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setString(1, username);
            pst.setInt(2, excludeId);

            ResultSet rs = pst.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("Error cek username: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Tambah user baru (digunakan saat registrasi oleh admin)
    public boolean addUser(User user) {
        String sql = "INSERT INTO users (username, password, role) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setString(1, user.getUsername());
            pst.setString(2, user.getPassword());
            pst.setString(3, user.getRole());

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error tambah user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Update user (password bisa kosong = tidak diubah)
    public boolean updateUser(User user) {
        String sql;
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            sql = "UPDATE users SET password = ?, role = ? WHERE id = ?";
        } else {
            sql = "UPDATE users SET role = ? WHERE id = ?";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            int index = 1;
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                pst.setString(index++, user.getPassword());
            }
            pst.setString(index++, user.getRole());
            pst.setInt(index, user.getId());

            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error update user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Hapus user berdasarkan ID
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setInt(1, id);
            return pst.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error hapus user: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Ambil semua user untuk ditampilkan di halaman manajemen
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, username, role FROM users ORDER BY username";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setRole(rs.getString("role"));
                // Password tidak diambil untuk keamanan (tidak ditampilkan)
                users.add(user);
            }
        } catch (SQLException e) {
            System.err.println("Error ambil semua user: " + e.getMessage());
            e.printStackTrace();
        }
        return users;
    }
}