<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.poswarungbakso.model.Product, com.poswarungbakso.model.StockHistory, java.util.*, java.time.*, java.time.format.DateTimeFormatter" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<StockHistory> history = (List<StockHistory>) request.getAttribute("history");
    String username = (String) request.getAttribute("username");
    String message = (String) request.getAttribute("message");
    String msgType = (String) request.getAttribute("msgType");

    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    ZoneId zone = ZoneId.of("Asia/Jakarta");

    // Untuk grafik: kumpulkan data per produk (10 teratas berdasarkan aktivitas terbaru)
    Map<String, List<String>> chartData = new LinkedHashMap<>();
    Set<String> topProducts = new LinkedHashSet<>();
    for (StockHistory h : history) {
        topProducts.add(h.getProductCode());
        if (topProducts.size() > 10) break;
    }
    for (String code : topProducts) {
        chartData.put(code, new ArrayList<>());
    }
    for (StockHistory h : history) {
        if (chartData.containsKey(h.getProductCode())) {
            Instant instant = Instant.ofEpochMilli(h.getTimestamp());
            String dateStr = LocalDateTime.ofInstant(instant, zone).toLocalDate().toString();
            chartData.get(h.getProductCode()).add("{x:'" + dateStr + "', y:" + h.getAfterStock() + "}");
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manajemen Stok - Warung Bakso Pak Farrel</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/jspdf@2.5.1/dist/jspdf.umd.min.js"></script>
  <style>
    .navbar-active{background:rgba(255,255,255,0.25)!important;font-weight:bold;border-radius:8px}
    #toast{position:fixed;bottom:30px;right:30px;padding:16px 32px;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.2);z-index:9999;font-weight:bold;opacity:0;transform:translateY(20px);transition:all .4s}
    #toast.show{opacity:1;transform:translateY(0)}
    #toast.success{background:#10b981;color:white}
    #toast.error{background:#ef4444;color:white}
    .change-positive{color:#10b981;font-weight:bold}
    .change-negative{color:#ef4444;font-weight:bold}
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
          <a href="UserServlet" class="px-5 py-3 rounded-lg navbar transition">Pengguna</a>
          <a href="StockServlet" class="px-5 py-3 rounded-lg navbar-active transition">Stok</a>
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
        <a href="DashboardServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Dasbor</a>
        <a href="../kasir/TransactionServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Transaksi</a>
        <a href="ProductServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Produk</a>
        <a href="UserServlet" class="px-5 py-3 rounded-lg navbar transition">Pengguna</a>
        <a href="StockServlet" class="block px-5 py-3 rounded-lg bg-blue-800 navbar-active">Stok</a>
        <a href="ReportServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Laporan</a>
        <a href="../index.jsp" class="block w-full bg-red-600 hover:bg-red-700 px-5 py-3 rounded-lg font-bold text-center">Keluar</a>
      </div>
    </div>
  </nav>

  <div class="container mx-auto px-4 py-8 max-w-7xl">
    <h2 class="text-4xl font-bold text-gray-800 mb-8 text-center">Manajemen Stok</h2>

    <% if (message != null) { %>
      <script>showToast("<%= message %>", "<%= msgType %>")</script>
    <% } %>

    <!-- Daftar Stok Saat Ini -->
    <div class="bg-white p-8 rounded-2xl shadow-xl mb-8">
      <div class="flex justify-between items-center mb-6">
        <h3 class="text-2xl font-bold">Daftar Stok Saat Ini</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-50">
            <tr>
              <th class="p-4 font-bold">Kode</th>
              <th class="p-4 font-bold">Nama Produk</th>
              <th class="p-4 font-bold text-center">Stok Saat Ini</th>
              <th class="p-4 font-bold text-center">Status</th>
              <th class="p-4 font-bold text-center">Quick Adjust</th>
            </tr>
          </thead>
          <tbody>
            <% if (products == null || products.isEmpty()) { %>
              <tr><td colspan="5" class="text-center py-16 text-gray-500 text-xl">Belum ada produk</td></tr>
            <% } else {
                for (Product p : products) {
                    String status = p.getStock() == 0 ? "Habis" : p.getStock() < 10 ? "Rendah" : p.getStock() < 30 ? "Sedang" : "Aman";
                    String color = p.getStock() == 0 ? "text-red-600" : p.getStock() < 10 ? "text-orange-600" : p.getStock() < 30 ? "text-yellow-600" : "text-green-600";
            %>
              <tr class="border-b hover:bg-gray-50">
                <td class="p-4 font-mono"><%= p.getCode() %></td>
                <td class="p-4 font-semibold text-lg"><%= p.getName() %></td>
                <td class="p-4 text-center text-2xl font-bold"><%= p.getStock() %></td>
                <td class="p-4 text-center"><span class="font-bold <%= color %>"><%= status %></span></td>
                <td class="p-4 text-center space-x-3">
                  <button onclick="quickAdjust('<%= p.getCode() %>', 10)" class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg font-bold">+</button>
                  <button onclick="quickAdjust('<%= p.getCode() %>', -10)" class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-lg font-bold">-</button>
                </td>
              </tr>
            <% } } %>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Penyesuaian Stok Manual -->
    <div class="bg-white p-8 rounded-2xl shadow-xl mb-8">
      <h3 class="text-2xl font-bold mb-6">Penyesuaian Stok Manual</h3>
      <form id="adjust-form" action="StockServlet" method="post" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div>
          <label class="block text-sm font-semibold mb-2">Pilih Produk</label>
          <select name="code" id="stock-product" required class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500">
            <option value="">Pilih Produk</option>
            <% for (Product p : products) { %>
              <option value="<%= p.getCode() %>"><%= p.getName() %> (<%= p.getCode() %>) - Stok: <%= p.getStock() %></option>
            <% } %>
          </select>
        </div>
        <div>
          <label class="block text-sm font-semibold mb-2">Jumlah (positif/tambah, negatif/kurang)</label>
          <input type="number" name="quantity" id="stock-quantity" required class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500" placeholder="ex: 50 atau -5">
        </div>
        <div>
          <label class="block text-sm font-semibold mb-2">Alasan</label>
          <select name="reason" id="stock-reason" required class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500" onchange="toggleCustomReason()">
            <option value="">Pilih Alasan</option>
            <option value="Restock">Restock</option>
            <option value="Retur Pelanggan">Retur Pelanggan</option>
            <option value="Kerusakan">Kerusakan</option>
            <option value="Koreksi">Koreksi</option>
            <option value="Lainnya">Lainnya</option>
          </select>
        </div>
        <div class="flex items-end">
          <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white w-full px-8 py-3 rounded-lg font-bold shadow-lg">Sesuaikan Stok</button>
        </div>
      </form>
      <div id="custom-reason" class="mt-6 hidden">
        <input type="text" form="adjust-form" name="reason" id="custom-reason-input" class="w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500" placeholder="Tulis alasan lainnya..." required>
      </div>
    </div>

    <!-- Riwayat Perubahan Stok -->
    <div class="bg-white p-8 rounded-2xl shadow-xl mb-8">
      <div class="flex justify-between items-center mb-6">
        <h3 class="text-2xl font-bold">Riwayat Perubahan Stok</h3>
        <div class="flex gap-4">
          <button onclick="exportCSV()" class="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-bold">CSV</button>
          <button onclick="exportPDF()" class="bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-lg font-bold">PDF</button>
        </div>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <input type="date" id="history-start" class="px-4 py-3 border rounded-lg">
        <input type="date" id="history-end" class="px-4 py-3 border rounded-lg">
        <button onclick="filterHistory()" class="bg-gray-700 hover:bg-gray-800 text-white px-8 py-3 rounded-lg font-bold">Filter</button>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-50">
            <tr>
              <th class="p-4 font-bold">Waktu</th>
              <th class="p-4 font-bold">Produk</th>
              <th class="p-4 font-bold text-center">Perubahan</th>
              <th class="p-4 font-bold">Alasan</th>
              <th class="p-4 font-bold text-center">Stok Setelah</th>
            </tr>
          </thead>
          <tbody id="stock-history-body">
            <% for (StockHistory h : history) {
                Instant instant = Instant.ofEpochMilli(h.getTimestamp());
                LocalDateTime ldt = LocalDateTime.ofInstant(instant, zone);
                String changeClass = h.getQuantity() > 0 ? "change-positive" : "change-negative";
                String changeText = h.getQuantity() > 0 ? "+" + h.getQuantity() : String.valueOf(h.getQuantity());
            %>
              <tr class="border-b hover:bg-gray-50">
                <td class="p-4 text-sm"><%= timeFmt.format(ldt) %></td>
                <td class="p-4 font-medium"><%= h.getProductName() %> (<%= h.getProductCode() %>)</td>
                <td class="p-4 text-center text-xl <%= changeClass %>"><%= changeText %></td>
                <td class="p-4"><%= h.getReason() %></td>
                <td class="p-4 text-center font-bold text-lg"><%= h.getAfterStock() %></td>
              </tr>
            <% } %>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Grafik Pergerakan Stok -->
    <div class="bg-white p-8 rounded-2xl shadow-xl">
      <h3 class="text-2xl font-bold mb-6">Grafik Pergerakan Stok (10 Produk Teratas)</h3>
      <div class="h-96">
        <canvas id="stock-chart"></canvas>
      </div>
    </div>
  </div>

  <div id="toast"></div>

  <script>
    // Quick Adjust (+/-10)
    function quickAdjust(code, qty) {
      if (!confirm('Yakin ' + (qty > 0 ? 'menambah' : 'mengurangi') + ' stok sebanyak ' + Math.abs(qty) + '?')) return;
      const form = document.createElement('form');
      form.method = 'post';
      form.action = 'StockServlet';
      const inputCode = document.createElement('input');
      inputCode.type = 'hidden';
      inputCode.name = 'code';
      inputCode.value = code;
      const inputQty = document.createElement('input');
      inputQty.type = 'hidden';
      inputQty.name = 'quantity';
      inputQty.value = qty;
      const inputReason = document.createElement('input');
      inputReason.type = 'hidden';
      inputReason.name = 'reason';
      inputReason.value = qty > 0 ? 'Restock Cepat' : 'Koreksi Cepat';
      form.appendChild(inputCode);
      form.appendChild(inputQty);
      form.appendChild(inputReason);
      document.body.appendChild(form);
      form.submit();
    }

    function toggleCustomReason() {
      const reason = document.getElementById('stock-reason').value;
      document.getElementById('custom-reason').classList.toggle('hidden', reason !== 'Lainnya');
      if (reason === 'Lainnya') {
        document.getElementById('custom-reason-input').required = true;
      } else {
        document.getElementById('custom-reason-input').required = false;
      }
    }

    function showToast(msg, type = 'success') {
      const toast = document.getElementById('toast');
      toast.textContent = msg;
      toast.className = type;
      toast.classList.add('show');
      setTimeout(() => toast.classList.remove('show'), 4000);
    }

    // Grafik
    const ctx = document.getElementById('stock-chart').getContext('2d');
    new Chart(ctx, {
      type: 'line',
      data: {
        datasets: [
          <% int colorIndex = 0;
             String[] colors = {"#3b82f6","#10b981","#f59e0b","#ef4444","#8b5cf6","#ec4899","#6366f1","#14b8a6","#f97316","#06b6d4"};
             for (Map.Entry<String, List<String>> entry : chartData.entrySet()) {
                 Product prod = products.stream().filter(p -> p.getCode().equals(entry.getKey())).findFirst().orElse(null);
                 String name = prod != null ? prod.getName() : entry.getKey();
          %>
          {
            label: '<%= name %>',
            data: [<%= String.join(",", entry.getValue()) %>],
            borderColor: '<%= colors[colorIndex++ % colors.length] %>',
            backgroundColor: 'transparent',
            tension: 0.3,
            pointRadius: 5
          }<%= colorIndex < chartData.size() ? "," : "" %>
          <% } %>
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: 'top' } },
        scales: { y: { beginAtZero: true } }
      }
    });

    // Export CSV Stok Saat Ini
    function exportCSV() {
      let csv = 'Kode,Nama,Stok,Status\n';
      <% for (Product p : products) {
          String status = p.getStock() == 0 ? "Habis" : p.getStock() < 10 ? "Rendah" : p.getStock() < 30 ? "Sedang" : "Aman";
      %>
      csv += '<%= p.getCode() %>,<%= p.getName() %>,<%= p.getStock() %>,<%= status %>\n';
      <% } %>
      const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'stok-saat-ini.csv';
      a.click();
      URL.revokeObjectURL(url);
    }

    // Export PDF Riwayat
    function exportPDF() {
      const { jsPDF } = window.jspdf;
      const doc = new jsPDF();
      doc.setFontSize(18);
      doc.text('Riwayat Perubahan Stok - Warung Bakso Pak Farrel', 105, 20, { align: 'center' });
      let y = 40;
      <% for (StockHistory h : history) {
          Instant instant = Instant.ofEpochMilli(h.getTimestamp());
          LocalDateTime ldt = LocalDateTime.ofInstant(instant, zone);
      %>
      if (y > 270) {
        doc.addPage();
        y = 20;
      }
      doc.setFontSize(9);
      doc.text('<%= timeFmt.format(ldt) %> | <%= h.getProductName() %> (<%= h.getProductCode() %>) <%= h.getQuantity() > 0 ? "+" : "" %><%= h.getQuantity() %> (<%= h.getReason() %>) → <%= h.getAfterStock() %>', 10, y);
      y += 8;
      <% } %>
      doc.save('riwayat-stok.pdf');
    }
  </script>
</body>
</html>