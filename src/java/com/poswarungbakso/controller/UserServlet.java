package com.poswarungbakso.controller;

import com.poswarungbakso.dao.UserDAO;
import com.poswarungbakso.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/UserServlet")
public class UserServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendRedirect("../index.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (id != currentUser.getId()) { // tidak boleh hapus diri sendiri
                userDAO.deleteUser(id);
                request.setAttribute("message", "Pengguna berhasil dihapus!");
                request.setAttribute("msgType", "success");
            } else {
                request.setAttribute("message", "Tidak bisa hapus diri sendiri!");
                request.setAttribute("msgType", "error");
            }
        }

        request.setAttribute("users", userDAO.getAllUsers());
        request.setAttribute("currentUserId", currentUser.getId());
        request.setAttribute("username", currentUser.getUsername());

        request.getRequestDispatcher("pengguna.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            response.sendRedirect("../index.jsp");
            return;
        }

        String action = request.getParameter("action");
        String username = request.getParameter("username").trim();
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        User user = new User();
        user.setUsername(username);
        user.setRole(role);

        boolean success = false;
        String message;

        if ("add".equals(action)) {
            if (userDAO.isUsernameExists(username)) {
                message = "Username sudah digunakan!";
            } else if (password == null || password.length() < 6) {
                message = "Password minimal 6 karakter!";
            } else {
                user.setPassword(password);
                success = userDAO.addUser(user);
                message = success ? "Pengguna berhasil ditambahkan!" : "Gagal tambah pengguna!";
            }
        } else { // edit
            int id = Integer.parseInt(request.getParameter("id"));
            user.setId(id);
            if (id == currentUser.getId() && "kasir".equals(role)) {
                message = "Tidak bisa ubah role diri sendiri menjadi kasir!";
            } else if (userDAO.isUsernameExists(username, id)) {
                message = "Username sudah digunakan oleh user lain!";
            } else {
                if (password != null && !password.isEmpty()) {
                    if (password.length() < 6) {
                        message = "Password baru minimal 6 karakter!";
                    } else {
                        user.setPassword(password);
                    }
                }
                success = userDAO.updateUser(user);
                message = success ? "Pengguna berhasil diupdate!" : "Gagal update pengguna!";
            }
        }

        request.setAttribute("message", message);
        request.setAttribute("msgType", success ? "success" : "error");

        doGet(request, response); // reload daftar
    }
}