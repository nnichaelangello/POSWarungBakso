package com.poswarungbakso.controller;

import com.poswarungbakso.dao.ProductDAO;
import com.poswarungbakso.dao.TransactionDAO;
import com.poswarungbakso.model.Product;
import com.poswarungbakso.model.Transaction;
import com.poswarungbakso.model.TransactionItem;
import com.poswarungbakso.model.User;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/kasir/TransactionServlet")
public class TransactionServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private TransactionDAO transactionDAO = new TransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || (!"admin".equals(user.getRole()) && !"kasir".equals(user.getRole()))) {
            response.sendRedirect("../index.jsp");
            return;
        }

        List<Product> products = productDAO.getAllProducts();
        List<Transaction> todayTransactions = transactionDAO.getTodayTransactions();
        int todayCount = transactionDAO.getTodayTransactionCount();
        int todayRevenue = transactionDAO.getTodayRevenue();

        request.setAttribute("products", products);
        request.setAttribute("todayTransactions", todayTransactions);
        request.setAttribute("todayCount", todayCount);
        request.setAttribute("todayRevenue", todayRevenue);
        request.setAttribute("username", user.getUsername());
        request.setAttribute("role", user.getRole());

        request.getRequestDispatcher("transaksi.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            response.sendRedirect("../index.jsp");
            return;
        }

        String[] codes = request.getParameterValues("code");
        String[] quantities = request.getParameterValues("quantity");

        if (codes == null || codes.length == 0) {
            response.sendRedirect("TransactionServlet?msg=empty");
            return;
        }

        List<TransactionItem> items = new ArrayList<>();
        int total = 0;

        for (int i = 0; i < codes.length; i++) {
            String code = codes[i];
            int qty;
            try {
                qty = Integer.parseInt(quantities[i]);
            } catch (NumberFormatException e) {
                response.sendRedirect("TransactionServlet?msg=error");
                return;
            }
            if (qty <= 0) continue;

            Product p = productDAO.getProductByCode(code);
            if (p == null || p.getStock() < qty) {
                response.sendRedirect("TransactionServlet?msg=stock");
                return;
            }

            TransactionItem item = new TransactionItem();
            item.setProductCode(code);
            item.setProductName(p.getName());
            item.setQuantity(qty);
            item.setPrice(p.getPrice());
            item.setSubtotal(p.getPrice() * qty);
            items.add(item);

            total += item.getSubtotal();
        }

        if (items.isEmpty()) {
            response.sendRedirect("TransactionServlet?msg=empty");
            return;
        }

        Transaction trans = new Transaction();
        trans.setTransactionCode("TRX" + System.currentTimeMillis() % 1000000);
        trans.setDate(System.currentTimeMillis());
        trans.setTotal(total);
        trans.setItems(items);

        boolean success = transactionDAO.saveTransaction(trans, user.getUsername());

        response.sendRedirect("TransactionServlet?msg=" + (success ? "success" : "error"));
    }
}