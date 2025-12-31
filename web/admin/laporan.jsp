<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.poswarungbakso.model.Transaction, com.poswarungbakso.model.TransactionItem, java.util.List, java.time.*, java.time.format.DateTimeFormatter" %>
<%
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    Integer totalTransactions = (Integer) request.getAttribute("totalTransactions");
    Integer totalRevenue = (Integer) request.getAttribute("totalRevenue");
    Double averageTransaction = (Double) request.getAttribute("averageTransaction");
    String topProduct = (String) request.getAttribute("topProduct");
    String username = (String) request.getAttribute("username");

    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    DateTimeFormatter fullFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    ZoneId zone = ZoneId.of("Asia/Jakarta");
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Laporan Penjualan - Warung Bakso Pak Farrel</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/jspdf@2.5.1/dist/jspdf.umd.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/jspdf-autotable@3.5.28/dist/jspdf.plugin.autotable.min.js"></script>
  <style>
    .navbar-active{background:rgba(255,255,255,0.25)!important;font-weight:bold;border-radius:8px}
    #toast{position:fixed;bottom:30px;right:30px;padding:16px 32px;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.2);z-index:9999;font-weight:bold;opacity:0;transform:translateY(20px);transition:all .4s}
    #toast.show{opacity:1;transform:translateY(0)}
    #toast.success{background:#10b981;color:white}
    #toast.error{background:#ef4444;color:white}
  </style>
</head>
<body class="bg-gray-100 min-h-screen">
  <nav class="bg-blue-700 text-white shadow-xl">
    <div class="container mx-auto px-4 py-4">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Warung Bakso Pak Farrel</h1>
        <div class="hidden md:flex items-center space-x-1">
          <a href="DashboardServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Dasbor</a>
          <a href="../kasir/TransactionServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Transaksi</a>
          <a href="ProductServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Produk</a>
          <a href="UserServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Pengguna</a>
          <a href="StockServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Stok</a>
          <a href="ReportServlet" class="px-5 py-3 rounded-lg navbar-active transition">Laporan</a>
          <a href="../index.jsp" class="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg font-bold ml-4 transition">Keluar</a>
        </div>
      </div>
    </div>
  </nav>

  <div class="container mx-auto px-4 py-8 max-w-7xl">
    <h2 class="text-4xl font-bold text-gray-800 mb-10 text-center">Laporan Penjualan</h2>

    <div class="bg-white p-8 rounded-2xl shadow-xl mb-8">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div class="bg-gradient-to-br from-blue-500 to-blue-700 text-white p-8 rounded-2xl shadow-2xl">
          <h3 class="text-xl font-bold mb-3">Total Transaksi</h3>
          <p class="text-4xl font-extrabold"><%= totalTransactions %></p>
        </div>
        <div class="bg-gradient-to-br from-green-500 to-green-700 text-white p-8 rounded-2xl shadow-2xl">
          <h3 class="text-xl font-bold mb-3">Total Pendapatan</h3>
          <p class="text-4xl font-extrabold">Rp <%= String.format("%,d", totalRevenue) %></p>
        </div>
        <div class="bg-gradient-to-br from-purple-500 to-purple-700 text-white p-8 rounded-2xl shadow-2xl">
          <h3 class="text-xl font-bold mb-3">Rata-rata Transaksi</h3>
          <p class="text-4xl font-extrabold">Rp <%= String.format("%,.0f", averageTransaction) %></p>
        </div>
        <div class="bg-gradient-to-br from-yellow-500 to-red-600 text-white p-8 rounded-2xl shadow-2xl">
          <h3 class="text-xl font-bold mb-3">Produk Terlaris</h3>
          <p class="text-2xl font-extrabold"><%= topProduct %></p>
        </div>
      </div>

      <div class="bg-white p-8 rounded-2xl shadow-2xl mb-10">
        <h3 class="text-2xl font-bold mb-6 text-gray-800">Grafik Pendapatan Harian</h3>
        <div class="h-96">
          <canvas id="sales-chart"></canvas>
        </div>
      </div>

      <div class="bg-white p-8 rounded-2xl shadow-2xl">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-2xl font-bold text-gray-800">Detail Transaksi</h3>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-left">
            <thead class="bg-gradient-to-r from-blue-600 to-blue-800 text-white">
              <tr>
                <th class="p-6 font-bold text-lg">ID</th>
                <th class="p-6 font-bold text-lg">Tanggal & Waktu</th>
                <th class="p-6 font-bold text-lg">Kasir</th>
                <th class="p-6 font-bold text-lg text-center">Total</th>
                <th class="p-6 font-bold text-lg text-center">Detail</th>
              </tr>
            </thead>
            <tbody>
              <% if (transactions.isEmpty()) { %>
                <tr><td colspan="5" class="text-center py-20 text-gray-500 text-2xl">Tidak ada transaksi</td></tr>
              <% } else {
                  for (Transaction t : transactions) {
                      Instant instant = Instant.ofEpochMilli(t.getDate());
                      LocalDateTime ldt = LocalDateTime.ofInstant(instant, zone);
              %>
                <tr class="border-b hover:bg-gray-50">
                  <td class="p-6 font-mono text-lg font-bold">#<%= t.getTransactionCode() %></td>
                  <td class="p-6 text-lg"><%= fullFmt.format(ldt) %></td>
                  <td class="p-6 font-semibold text-blue-600"><%= t.getCashier() %></td>
                  <td class="p-6 text-right text-2xl font-extrabold text-green-600">Rp <%= String.format("%,d", t.getTotal()) %></td>
                  <td class="p-6 text-center">
                    <button onclick="toggleDetail('<%= t.getTransactionCode() %>')" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-xl font-bold">Detail</button>
                  </td>
                </tr>
                <tr id="detail-<%= t.getTransactionCode() %>" class="hidden bg-gradient-to-r from-blue-50 to-indigo-50">
                  <td colspan="5" class="p-8">
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                      <div>
                        <h4 class="font-bold text-xl mb-4 text-blue-800">Daftar Item:</h4>
                        <% for (TransactionItem item : t.getItems()) { %>
                          <div class="flex justify-between py-2 border-b">
                            <span><%= item.getProductName() %> × <%= item.getQuantity() %></span>
                            <span class="font-semibold">Rp <%= String.format("%,d", item.getSubtotal()) %></span>
                          </div>
                        <% } %>
                      </div>
                      <div class="bg-white p-6 rounded-xl shadow-lg">
                        <h4 class="font-bold text-xl mb-4 text-green-800">Ringkasan</h4>
                        <div class="flex justify-between text-2xl font-extrabold text-green-600 pt-4 border-t-4 border-green-600">
                          <span>TOTAL</span><span>Rp <%= String.format("%,d", t.getTotal()) %></span>
                        </div>
                      </div>
                    </div>
                  </td>
                </tr>
              <% } } %>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <script>
      function toggleDetail(code) {
        const el = document.getElementById('detail-' + code);
        el.classList.toggle('hidden');
      }

      // Grafik pendapatan harian
      const dailyData = {};
      <% for (Transaction t : transactions) {
          Instant instant = Instant.ofEpochMilli(t.getDate());
          String day = LocalDate.ofInstant(instant, zone).format(dateFmt);
      %>
        dailyData['<%= day %>'] = (dailyData['<%= day %>'] || 0) + <%= t.getTotal() %>;
      <% } %>

      const labels = Object.keys(dailyData).sort();
      const data = labels.map(l => dailyData[l]);

      new Chart(document.getElementById('sales-chart'), {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{
            label: 'Pendapatan Harian (Rp)',
            data: data,
            borderColor: '#3b82f6',
            backgroundColor: 'rgba(59,130,246,0.1)',
            fill: true,
            tension: 0.4
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          scales: { y: { beginAtZero: true, ticks: { callback: v => 'Rp ' + v.toLocaleString('id-ID') } } }
        }
      });
    </script>
  </body>
</html>