package com.poswarungbakso.controller;

import com.poswarungbakso.dao.ProductDAO;
import com.poswarungbakso.model.Product;
import com.poswarungbakso.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/ProductServlet")
public class ProductServlet extends HttpServlet {

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

        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = productDAO.deleteProduct(id);
            response.sendRedirect("ProductServlet?delete=" + (success ? "success" : "error"));
            return;
        }

        // Default: tampilkan daftar produk
        String search = request.getParameter("search");
        if (search != null && !search.trim().isEmpty()) {
            request.setAttribute("products", productDAO.searchProducts(search.trim()));
            request.setAttribute("searchKeyword", search.trim());
        } else {
            request.setAttribute("products", productDAO.getAllProducts());
        }

        String deleteMsg = request.getParameter("delete");
        if ("success".equals(deleteMsg)) {
            request.setAttribute("message", "Produk berhasil dihapus!");
            request.setAttribute("msgType", "success");
        } else if ("error".equals(deleteMsg)) {
            request.setAttribute("message", "Gagal menghapus produk!");
            request.setAttribute("msgType", "error");
        }

        request.setAttribute("username", user.getUsername());
        request.getRequestDispatcher("produk.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String code = request.getParameter("code");
        String name = request.getParameter("name");
        int price = Integer.parseInt(request.getParameter("price"));
        int stock = Integer.parseInt(request.getParameter("stock"));

        Product product = new Product();
        product.setCode(code);
        product.setName(name);
        product.setPrice(price);
        product.setStock(stock);

        boolean success;
        if ("add".equals(action)) {
            success = productDAO.addProduct(product);
        } else { // edit
            int id = Integer.parseInt(request.getParameter("id"));
            product.setId(id);
            success = productDAO.updateProduct(product);
        }

        response.sendRedirect("ProductServlet?save=" + (success ? "success" : "error"));
    }
}