package com.poswarungbakso.controller;

import com.poswarungbakso.dao.DashboardDAO;
import com.poswarungbakso.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    private DashboardDAO dashboardDAO = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect("../index.jsp");
            return;
        }

        // Ambil semua data
        request.setAttribute("products", dashboardDAO.getAllProducts());
        request.setAttribute("transactions", dashboardDAO.getAllTransactions());
        request.setAttribute("logs", dashboardDAO.getAllActivityLogs());
        request.setAttribute("username", user.getUsername());

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}