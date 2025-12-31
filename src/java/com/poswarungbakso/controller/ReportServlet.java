package com.poswarungbakso.controller;

import com.poswarungbakso.dao.ReportDAO;
import com.poswarungbakso.model.Transaction;
import com.poswarungbakso.model.User;
import java.io.IOException;
import java.time.*;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/ReportServlet")
public class ReportServlet extends HttpServlet {

    private ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null || !"admin".equals(user.getRole())) {
            response.sendRedirect("../index.jsp");
            return;
        }

        // Default: laporan harian (hari ini)
        ZoneId zone = ZoneId.of("Asia/Jakarta");
        LocalDate today = LocalDate.now(zone);
        long start = today.atStartOfDay(zone).toInstant().toEpochMilli();
        long end = today.plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli() - 1;

        // Jika ada parameter custom
        String type = request.getParameter("type");
        if (type != null) {
            LocalDate now = LocalDate.now(zone);
            switch (type) {
                case "weekly":
                    LocalDate monday = now.with(DayOfWeek.MONDAY);
                    start = monday.atStartOfDay(zone).toInstant().toEpochMilli();
                    end = now.plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli() - 1;
                    break;
                case "monthly":
                    LocalDate firstDay = now.withDayOfMonth(1);
                    start = firstDay.atStartOfDay(zone).toInstant().toEpochMilli();
                    end = now.plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli() - 1;
                    break;
                case "yearly":
                    LocalDate firstJan = now.withDayOfYear(1);
                    start = firstJan.atStartOfDay(zone).toInstant().toEpochMilli();
                    end = now.plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli() - 1;
                    break;
                case "custom":
                    String s = request.getParameter("start");
                    String e = request.getParameter("end");
                    if (s != null && e != null && !s.isEmpty() && !e.isEmpty()) {
                        start = LocalDate.parse(s).atStartOfDay(zone).toInstant().toEpochMilli();
                        end = LocalDate.parse(e).plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli() - 1;
                    }
                    break;
            }
        }

        List<Transaction> transactions = reportDAO.getTransactionsByRange(start, end);
        int totalTrans = reportDAO.getTotalTransactions(start, end);
        int totalRev = reportDAO.getTotalRevenue(start, end);
        double avgTrans = reportDAO.getAverageTransaction(start, end);
        String topProduct = reportDAO.getTopProduct(start, end);

        request.setAttribute("transactions", transactions);
        request.setAttribute("totalTransactions", totalTrans);
        request.setAttribute("totalRevenue", totalRev);
        request.setAttribute("averageTransaction", avgTrans);
        request.setAttribute("topProduct", topProduct);
        request.setAttribute("username", user.getUsername());

        request.getRequestDispatcher("laporan.jsp").forward(request, response);
    }
}