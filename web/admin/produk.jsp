<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.poswarungbakso.model.Product, java.util.List" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    String username = (String) request.getAttribute("username");
    String message = (String) request.getAttribute("message");
    String msgType = (String) request.getAttribute("msgType");
    String searchKeyword = (String) request.getAttribute("searchKeyword");
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manajemen Produk - Warung Bakso Pak Farrel</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <style>
    .navbar-active{background:rgba(255,255,255,0.25)!important;font-weight:bold;border-radius:8px}
    #toast{position:fixed;bottom:30px;right:30px;padding:16px 32px;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.2);z-index:9999;font-weight:bold;opacity:0;transform:translateY(20px);transition:all .4s}
    #toast.show{opacity:1;transform:translateY(0)}
    #toast.success{background:#10b981;color:white}
    #toast.error{background:#ef4444;color:white}
  </style>
</head>
<body class="bg-gray-100 min-h-screen">
  <!-- Navbar -->
  <nav class="bg-blue-700 text-white shadow-xl">
    <div class="container mx-auto px-4 py-4">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Warung Bakso Pak Farrel</h1>
        <div class="hidden md:flex items-center space-x-1">
          <a href="DashboardServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Dasbor</a>
          <a href="../kasir/TransactionServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Transaksi</a>
          <a href="ProductServlet" class="px-5 py-3 rounded-lg navbar-active transition">Produk</a>
          <a href="UserServlet" class="px-5 py-3 rounded-lg navbar transition">Pengguna</a>
          <a href="StockServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Stok</a>
          <a href="ReportServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Laporan</a>
          <a href="../index.jsp" class="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg font-bold ml-4 transition">Keluar</a>
        </div>
        <!-- Mobile menu sama seperti sebelumnya -->
        <button class="md:hidden" onclick="document.getElementById('mobile-menu').classList.toggle('hidden')">
          <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
          </svg>
        </button>
      </div>
      <div id="mobile-menu" class="md:hidden hidden mt-4 space-y-2">
        <a href="DashboardServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Dasbor</a>
        <a href="../kasir/TransactionServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Transaksi</a>
        <a href="ProductServlet" class="block px-5 py-3 rounded-lg bg-blue-800 navbar-active">Produk</a>
        <a href="UserServlet" class="px-5 py-3 rounded-lg navbar transition">Pengguna</a>
        <a href="StockServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Stok</a>
        <a href="ReportServlet" class="block px-5 py-3 rounded-lg hover:bg-blue-600">Laporan</a>
        <a href="../index.jsp" class="block w-full bg-red-600 hover:bg-red-700 px-5 py-3 rounded-lg font-bold text-center">Keluar</a>
      </div>
    </div>
  </nav>

  <div class="container mx-auto px-4 py-8 max-w-7xl">
    <div class="flex justify-between items-center mb-8">
      <h2 class="text-4xl font-bold text-gray-800">Manajemen Produk</h2>
      <button onclick="openModal('add')" class="bg-green-600 hover:bg-green-700 text-white px-8 py-4 rounded-xl font-bold text-lg shadow-xl transition transform hover:scale-105">
        + Tambah Produk
      </button>
    </div>

    <!-- Search -->
    <div class="mb-8">
      <form action="ProductServlet" method="get" class="flex gap-4">
        <input type="text" name="search" value="<%= searchKeyword != null ? searchKeyword : "" %>" placeholder="Cari kode atau nama produk..." class="flex-1 px-6 py-4 border-2 border-gray-300 rounded-xl text-lg focus:ring-4 focus:ring-blue-300">
        <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-8 py-4 rounded-xl font-bold">Cari</button>
        <% if (searchKeyword != null) { %>
          <a href="ProductServlet" class="bg-gray-500 hover:bg-gray-600 text-white px-8 py-4 rounded-xl font-bold">Reset</a>
        <% } %>
      </form>
    </div>

    <!-- Notifikasi -->
    <% if (message != null) { %>
      <script>showToast("<%= message %>", "<%= msgType %>")</script>
    <% } %>

    <!-- Table Produk -->
    <div class="bg-white rounded-2xl shadow-2xl overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
            <tr>
              <th class="p-6 text-left text-lg font-bold">Kode</th>
              <th class="p-6 text-left text-lg font-bold">Nama Produk</th>
              <th class="p-6 text-left text-lg font-bold">Harga</th>
              <th class="p-6 text-left text-lg font-bold">Stok</th>
              <th class="p-6 text-left text-lg font-bold">Aksi</th>
            </tr>
          </thead>
          <tbody class="text-gray-800">
            <% if (products.isEmpty()) { %>
              <tr>
                <td colspan="5" class="text-center py-16 text-2xl text-gray-500">Belum ada produk</td>
              </tr>
            <% } else {
                for (Product p : products) { %>
              <tr class="border-b hover:bg-gray-50 transition">
                <td class="p-6 font-bold"><%= p.getCode() %></td>
                <td class="p-6 text-lg"><%= p.getName() %></td>
                <td class="p-6">Rp <%= String.format("%,d", p.getPrice()) %></td>
                <td class="p-6">
                  <span class="<%= p.getStock() < 10 ? "text-red-600 font-bold" : "" %>"><%= p.getStock() %></span>
                </td>
                <td class="p-6">
                  <button onclick='openModal("edit", <%= p.getId() %>, "<%= p.getCode() %>", "<%= p.getName() %>", <%= p.getPrice() %>, <%= p.getStock() %>)' 
                          class="bg-yellow-500 hover:bg-yellow-600 text-white px-4 py-2 rounded-lg mr-2 font-bold">Edit</button>
                  <a href="ProductServlet?action=delete&id=<%= p.getId() %>" 
                     onclick="return confirm('Yakin hapus produk <%= p.getName() %>?')"
                     class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg font-bold">Hapus</a>
                </td>
              </tr>
            <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Modal Tambah/Edit -->
  <div id="product-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
    <div class="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-lg">
      <h3 id="modal-title" class="text-3xl font-bold text-gray-800 mb-8">Tambah Produk Baru</h3>
      <form id="product-form" action="ProductServlet" method="post">
        <input type="hidden" name="action" id="form-action" value="add">
        <input type="hidden" name="id" id="product-id">
        <div class="space-y-6">
          <input type="text" name="code" id="code" required placeholder="Kode Produk (ex: BKS001)" class="w-full px-6 py-4 border-2 border-gray-300 rounded-xl text-lg">
          <input type="text" name="name" id="name" required placeholder="Nama Produk" class="w-full px-6 py-4 border-2 border-gray-300 rounded-xl text-lg">
          <input type="number" name="price" id="price" required min="1" placeholder="Harga" class="w-full px-6 py-4 border-2 border-gray-300 rounded-xl text-lg">
          <input type="number" name="stock" id="stock" required min="0" placeholder="Stok Awal" class="w-full px-6 py-4 border-2 border-gray-300 rounded-xl text-lg">
        </div>
        <div class="flex justify-end gap-4 mt-8">
          <button type="button" onclick="closeModal()" class="px-8 py-4 border-2 border-gray-300 rounded-xl font-bold hover:bg-gray-100">Batal</button>
          <button type="submit" class="px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold">Simpan</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Toast -->
  <div id="toast"></div>

  <script>
    function openModal(mode, id = '', code = '', name = '', price = '', stock = '') {
      document.getElementById('modal-title').textContent = mode === 'add' ? 'Tambah Produk Baru' : 'Edit Produk';
      document.getElementById('form-action').value = mode;
      document.getElementById('product-id').value = id;
      document.getElementById('code').value = code;
      document.getElementById('name').value = name;
      document.getElementById('price').value = price;
      document.getElementById('stock').value = stock;
      document.getElementById('product-modal').classList.remove('hidden');
      document.getElementById('product-modal').classList.add('flex');
    }

    function closeModal() {
      document.getElementById('product-modal').classList.add('hidden');
      document.getElementById('product-modal').classList.remove('flex');
    }

    function showToast(msg, type = 'success') {
      const toast = document.getElementById('toast');
      toast.textContent = msg;
      toast.className = type;
      toast.classList.add('show');
      setTimeout(() => toast.classList.remove('show'), 4000);
    }

    // Tutup modal kalau klik luar
    document.getElementById('product-modal').addEventListener('click', (e) => {
      if (e.target === document.getElementById('product-modal')) closeModal();
    });
  </script>
</body>
</html>