package com.poswarungbakso.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/pos_warungbakso?useSSL=false&serverTimezone=Asia/Jakarta&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASS = "";  // XAMPP default kosong

    public static Connection getConnection() {
        try {
            // Pastikan driver di-load (penting untuk beberapa versi)
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(URL, USER, PASS);
            System.out.println("Koneksi MySQL berhasil!");  // Untuk debug di console Tomcat
            return conn;
        } catch (ClassNotFoundException e) {
            System.err.println("Driver MySQL tidak ditemukan: " + e.getMessage());
            return null;
        } catch (SQLException e) {
            System.err.println("Koneksi database gagal: " + e.getMessage());
            e.printStackTrace();  // Tampilkan detail error
            return null;
        }
    }
}