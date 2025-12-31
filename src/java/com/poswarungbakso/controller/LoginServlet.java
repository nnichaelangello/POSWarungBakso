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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = userDAO.login(username, password);

        if (user != null) {
            // Login sukses → simpan ke session
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", user);

            // Redirect sesuai role
            if ("admin".equals(user.getRole())) {
                response.sendRedirect("admin/DashboardServlet");
            } else {
                response.sendRedirect("kasir/TransactionServlet");
            }
        } else {
            // Login gagal
            request.setAttribute("message", "Username atau password salah!");
            request.setAttribute("messageType", "text-red-300");
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Jika akses langsung via GET, arahkan ke login
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}