package com.poswarungbakso.controller;

import com.poswarungbakso.dao.ProductDAO;
import com.poswarungbakso.model.Product;
import com.poswarungbakso.model.StockHistory;
import com.poswarungbakso.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

@WebServlet("/admin/StockServlet")
public class StockServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect("../index.jsp");
            return;
        }

        // Ambil data
        List<Product> products = productDAO.getAllProducts();
        List<StockHistory> history = productDAO.getAllStockHistory();

        request.setAttribute("products", products);
        request.setAttribute("history", history);
        request.setAttribute("username", user.getUsername());

        String msg = request.getParameter("msg");
        if ("success".equals(msg)) {
            request.setAttribute("message", "Stok berhasil disesuaikan!");
            request.setAttribute("msgType", "success");
        } else if ("error".equals(msg)) {
            request.setAttribute("message", "Gagal menyesuaikan stok!");
            request.setAttribute("msgType", "error");
        }

        request.getRequestDispatcher("stok.jsp").forward(request, response);
    }

        @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String code = request.getParameter("code");
        String qtyParam = request.getParameter("quantity");
        String reason = request.getParameter("reason");

        if (code == null || qtyParam == null || reason == null || reason.trim().isEmpty()) {
            response.sendRedirect("StockServlet?msg=error");
            return;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(qtyParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("StockServlet?msg=error");
            return;
        }

        Product product = productDAO.getProductByCode(code);
        if (product == null || product.getStock() + quantity < 0) {
            response.sendRedirect("StockServlet?msg=error");
            return;
        }

        int newStock = product.getStock() + quantity;
        long timestamp = System.currentTimeMillis();

        boolean stockUpdated = productDAO.updateStock(code, newStock);
        boolean historyAdded = productDAO.addStockHistory(code, product.getName(), quantity, reason, newStock, timestamp);

        if (stockUpdated && historyAdded) {
            response.sendRedirect("StockServlet?msg=success");
        } else {
            response.sendRedirect("StockServlet?msg=error");
        }
    }
}