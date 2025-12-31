<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%
    // Cek session dan role
    com.poswarungbakso.model.User currentUser = (com.poswarungbakso.model.User) session.getAttribute("currentUser");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<%@ page import="com.poswarungbakso.model.*, java.util.*" %>
<%@ page import="java.time.*, java.time.format.*, java.text.NumberFormat" %>
<%
    // Ambil data dari DashboardServlet
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    List<ActivityLog> logs = (List<ActivityLog>) request.getAttribute("logs");
    String username = (String) request.getAttribute("username");

    // Helper untuk format rupiah dan tanggal
    NumberFormat rupiah = NumberFormat.getCurrencyInstance(new Locale("id", "ID"));
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd MMM");
    DateTimeFormatter fullDateFmt = DateTimeFormatter.ofPattern("cccc, d LLLL yyyy • HH:mm:ss");
    ZoneId zone = ZoneId.of("Asia/Jakarta");
    LocalDateTime now = LocalDateTime.now(zone);

    // Hitung KPI
    long todayStart = LocalDate.now(zone).atStartOfDay(zone).toInstant().toEpochMilli();
    long weekStart = LocalDate.now(zone).minusDays(6).atStartOfDay(zone).toInstant().toEpochMilli();
    long monthStart = LocalDate.now(zone).withDayOfMonth(1).atStartOfDay(zone).toInstant().toEpochMilli();

    long dailySales = 0, weeklySales = 0, monthlyItemsSold = 0, dailyCount = 0;
    int lowStockCount = 0;

    for (Product p : products) {
        if (p.getStock() < 10) lowStockCount++;
    }

    for (Transaction t : transactions) {
        long txDate = t.getDate();
        if (txDate >= todayStart) {
            dailySales += t.getTotal();
            dailyCount++;
        }
        if (txDate >= weekStart) {
            weeklySales += t.getTotal();
        }
        if (txDate >= monthStart) {
            for (TransactionItem item : t.getItems()) {
                monthlyItemsSold += item.getQuantity();
            }
        }
    }

    // Data untuk Chart (7 hari terakhir)
    StringBuilder chartLabels = new StringBuilder();
    StringBuilder chartData = new StringBuilder();
    for (int i = 6; i >= 0; i--) {
        long dayStart = LocalDate.now(zone).minusDays(i).atStartOfDay(zone).toInstant().toEpochMilli();
        long dayEnd = dayStart + 86400000;
        long dayTotal = 0;
        for (Transaction t : transactions) {
            if (t.getDate() >= dayStart && t.getDate() < dayEnd) {
                dayTotal += t.getTotal();
            }
        }
        chartLabels.append("'").append(LocalDate.now(zone).minusDays(i).format(dateFmt)).append("'");
        chartData.append(dayTotal);
        if (i > 0) {
            chartLabels.append(",");
            chartData.append(",");
        }
    }

    // Top 5 Produk Terlaris (berdasarkan quantity terjual bulan ini)
    Map<String, Long> salesMap = new HashMap<>();
    Map<String, Integer> productPriceMap = new HashMap<>();
    for (Product p : products) {
        productPriceMap.put(p.getCode(), p.getPrice());
    }
    for (Transaction t : transactions) {
        if (t.getDate() >= monthStart) {
            for (TransactionItem item : t.getItems()) {
                String code = item.getProductCode();
                salesMap.put(code, salesMap.getOrDefault(code, 0L) + item.getQuantity());
            }
        }
    }
    List<Map.Entry<String, Long>> top5 = new ArrayList<>(salesMap.entrySet());
    top5.sort((a, b) -> b.getValue().compareTo(a.getValue()));
    if (top5.size() > 5) top5 = top5.subList(0, 5);
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dasbor - Warung Bakso Pak Farrel</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    .navbar-active{background:rgba(255,255,255,0.25)!important;font-weight:bold;border-radius:8px}
    #toast{position:fixed;bottom:30px;right:30px;background:#10b981;color:white;padding:16px 32px;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.2);z-index:9999;font-weight:bold;opacity:0;transform:translateY(20px);transition:all .4s}
    #toast.show{opacity:1;transform:translateY(0)}
    #toast.error{background:#ef4444}
  </style>
</head>
<body class="bg-gray-100 min-h-screen">
  <nav class="bg-blue-700 text-white shadow-xl">
    <div class="container mx-auto px-4 py-4">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Warung Bakso Pak Farrel</h1>
        <div class="hidden md:flex items-center space-x-1">
          <a href="DashboardServlet" class="px-5 py-3 rounded-lg transition navbar-active">Dasbor</a>
          <a href="../kasir/TransactionServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Transaksi</a>
          <a href="ProductServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Produk</a>
          <a href="UserServlet" class="px-5 py-3 rounded-lg navbar transition">Pengguna</a>
          <a href="StockServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Stok</a>
          <a href="ReportServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Laporan</a>
          <a href="../index.jsp" class="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg font-bold ml-4 transition">Keluar</a>
        </div>
        <button class="md:hidden" onclick="document.getElementById('mobile-menu').classList.toggle('hidden')">
          <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      </div>
      <div id="mobile-menu" class="md:hidden hidden mt-4 space-y-2">
        <a href="DashboardServlet" class="block px-5 py-3 rounded-lg bg-blue-800 navbar-active">Dasbor</a>
        <a href="../kasir/TransactionServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Transaksi</a>
        <a href="ProductServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Produk</a>
        <a href="UserServlet" class="px-5 py-3 rounded-lg navbar transition">Pengguna</a>
        <a href="StockServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Stok</a>
        <a href="ReportServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Laporan</a>
        <a href="../index.jsp" class="block w-full bg-red-600 hover:bg-red-700 px-5 py-3 rounded-lg font-bold text-center">Keluar</a>
      </div>
    </div>
  </nav>

  <div class="container mx-auto px-4 py-8 max-w-7xl">
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-10">
      <div>
        <h2 class="text-4xl font-bold text-gray-800">Selamat Datang, <%= username %>!</h2>
        <p class="text-xl text-gray-600 mt-3"><%= fullDateFmt.format(now) %></p>
      </div>
      <div class="flex gap-4 mt-6 md:mt-0">
        <a href="DashboardServlet" class="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-xl font-bold text-lg shadow-xl transition transform hover:scale-105">Refresh</a>
      </div>
    </div>

    <!-- KPI Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-12">
      <div class="bg-gradient-to-br from-green-500 to-green-700 text-white p-8 rounded-2xl shadow-2xl transform hover:scale-105 transition">
        <p class="text-xl font-semibold opacity-90">Penjualan Hari Ini</p>
        <p class="text-4xl font-extrabold mt-4"><%= rupiah.format(dailySales) %></p>
        <p class="text-lg mt-3 opacity-90"><%= dailyCount %> transaksi</p>
      </div>
      <div class="bg-gradient-to-br from-blue-500 to-blue-700 text-white p-8 rounded-2xl shadow-2xl transform hover:scale-105 transition">
        <p class="text-xl font-semibold opacity-90">Pendapatan Minggu Ini</p>
        <p class="text-4xl font-extrabold mt-4"><%= rupiah.format(weeklySales) %></p>
      </div>
      <div class="bg-gradient-to-br from-purple-500 to-purple-700 text-white p-8 rounded-2xl shadow-2xl transform hover:scale-105 transition">
        <p class="text-xl font-semibold opacity-90">Produk Terjual Bulan Ini</p>
        <p class="text-4xl font-extrabold mt-4"><%= String.format("%,d", monthlyItemsSold) %></p>
        <p class="text-lg mt-3 opacity-90">dari <%= transactions.stream().filter(t -> t.getDate() >= monthStart).count() %> transaksi</p>
      </div>
      <div class="bg-gradient-to-br from-red-500 to-red-700 text-white p-8 rounded-2xl shadow-2xl transform hover:scale-105 transition">
        <p class="text-xl font-semibold opacity-90">Stok Rendah</p>
        <p class="text-6xl font-extrabold mt-4"><%= lowStockCount %></p>
        <p class="text-lg mt-3 opacity-90">dari <%= products.size() %> produk</p>
      </div>
    </div>

    <!-- Chart + Top Products -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
      <div class="lg:col-span-2 bg-white p-8 rounded-2xl shadow-2xl">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-3xl font-bold text-gray-800">Tren Penjualan 7 Hari</h3>
        </div>
        <div class="h-96"><canvas id="sales-chart"></canvas></div>
      </div>
      <div class="bg-white p-8 rounded-2xl shadow-2xl">
        <h3 class="text-3xl font-bold text-gray-800 mb-8">Top 5 Produk Terlaris (Bulan Ini)</h3>
        <div class="space-y-6">
          <% if (top5.isEmpty()) { %>
            <p class="text-center text-gray-500 text-xl py-10">Belum ada penjualan bulan ini</p>
          <% } else {
              int rank = 1;
              for (Map.Entry<String, Long> entry : top5) {
                  String code = entry.getKey();
                  long qty = entry.getValue();
                  Product prod = products.stream().filter(p -> p.getCode().equals(code)).findFirst().orElse(null);
                  String name = prod != null ? prod.getName() : code;
                  int price = prod != null ? prod.getPrice() : 0;
                  long revenue = qty * price;
          %>
            <div class="flex items-center justify-between p-6 bg-gradient-to-r from-blue-50 to-purple-50 rounded-2xl shadow-lg">
              <div class="flex items-center gap-5">
                <div class="w-16 h-16 rounded-full bg-gradient-to-br from-blue-600 to-purple-600 flex items-center justify-center text-white text-2xl font-bold shadow-xl">
                  <%= rank++ %>
                </div>
                <div>
                  <p class="text-2xl font-bold text-gray-800"><%= name %></p>
                  <p class="text-lg text-gray-600"><%= String.format("%,d", qty) %> terjual</p>
                </div>
              </div>
              <p class="text-xl font-extrabold text-green-600"><%= rupiah.format(revenue) %></p>
            </div>
          <% } } %>
        </div>
      </div>
    </div>

    <!-- Activity Log -->
<!--    <div class="bg-white p-8 rounded-2xl shadow-2xl">
      <h3 class="text-3xl font-bold text-gray-800 mb-8">Aktivitas Terbaru</h3>
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
            <tr>
              <th class="p-6 text-lg font-bold rounded-tl-xl">Waktu</th>
              <th class="p-6 text-lg font-bold">Pengguna</th>
              <th class="p-6 text-lg font-bold rounded-tr-xl">Aktivitas</th>
            </tr>
          </thead>
          <tbody class="text-gray-800">
            <% if (logs.isEmpty()) { %>
              <tr><td colspan="3" class="text-center py-20 text-gray-500 text-2xl">Tidak ada aktivitas</td></tr>
            <% } else {
                for (ActivityLog log : logs) {
                    Instant instant = Instant.ofEpochMilli(log.getTimestamp());
                    LocalDateTime ldt = LocalDateTime.ofInstant(instant, zone);
                    String timeStr = ldt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
                    String[] parts = log.getActivity().split(" - ");
                    String activity = parts[0];
                    String userLog = parts.length > 1 ? parts[1] : "Sistem";
            %>
              <tr class="border-b hover:bg-gray-50 transition">
                <td class="p-6 text-lg"><%= timeStr %></td>
                <td class="p-6 font-bold text-blue-600"><%= userLog %></td>
                <td class="p-6 text-lg"><%= activity %></td>
              </tr>
            <% } } %>
          </tbody>
        </table>
      </div>
    </div>-->
  </div>

  <!-- Chart Script -->
  <script>
    const ctx = document.getElementById('sales-chart').getContext('2d');
    new Chart(ctx, {
      type: 'line',
      data: {
        labels: [<%= chartLabels.toString() %>],
        datasets: [{
          label: 'Penjualan (Rp)',
          data: [<%= chartData.toString() %>],
          borderColor: '#10b981',
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          fill: true,
          tension: 0.4,
          pointRadius: 6,
          pointBackgroundColor: '#10b981'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          y: {
            beginAtZero: true,
            ticks: { callback: value => 'Rp ' + value.toLocaleString('id-ID') }
          }
        }
      }
    });
  </script>
</body>
</html>