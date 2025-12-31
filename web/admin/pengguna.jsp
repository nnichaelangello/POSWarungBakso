<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.poswarungbakso.model.User, java.util.List" %>
<%
    List<User> users = (List<User>) request.getAttribute("users");
    Integer currentUserId = (Integer) request.getAttribute("currentUserId");
    String username = (String) request.getAttribute("username");
    String message = (String) request.getAttribute("message");
    String msgType = (String) request.getAttribute("msgType");
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manajemen Pengguna - Warung Bakso Pak Farrel</title>
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
  <nav class="bg-blue-700 text-white shadow-xl">
    <div class="container mx-auto px-4 py-4">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Warung Bakso Pak Farrel</h1>
        <div class="hidden md:flex items-center space-x-1">
          <a href="DashboardServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Dasbor</a>
          <a href="../kasir/TransactionServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Transaksi</a>
          <a href="ProductServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Produk</a>
          <a href="UserServlet" class="px-5 py-3 rounded-lg navbar-active transition">Pengguna</a>
          <a href="StockServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Stok</a>
          <a href="ReportServlet" class="px-5 py-3 rounded-lg hover:bg-blue-600 transition">Laporan</a>
          <a href="../index.jsp" class="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg font-bold ml-4 transition">Keluar</a>
        </div>
        <!-- Mobile menu -->
      </div>
    </div>
  </nav>

  <div class="container mx-auto px-4 py-8 max-w-6xl">
    <h2 class="text-4xl font-bold text-gray-800 mb-10 text-center">Manajemen Pengguna & Akses</h2>

    <% if (message != null) { %>
      <script>showToast("<%= message %>", "<%= msgType %>")</script>
    <% } %>

    <div class="bg-white p-10 rounded-2xl shadow-2xl mb-10">
      <form action="UserServlet" method="post">
        <input type="hidden" name="action" value="add" id="form-action">
        <input type="hidden" name="id" id="user-id">
        <h3 class="text-2xl font-bold mb-8 text-gray-700">Tambah Pengguna Baru</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <label class="block text-lg font-semibold mb-3 text-gray-700">Username</label>
            <input type="text" name="username" id="user-username" required class="w-full px-5 py-4 border-2 rounded-xl focus:ring-4 focus:ring-blue-300 text-lg" placeholder="masukkan username">
          </div>
          <div>
            <label class="block text-lg font-semibold mb-3 text-gray-700">Password</label>
            <input type="password" name="password" id="user-password" required class="w-full px-5 py-4 border-2 rounded-xl focus:ring-4 focus:ring-blue-300 text-lg" placeholder="minimal 6 karakter">
          </div>
          <div>
            <label class="block text-lg font-semibold mb-3 text-gray-700">Role Akses</label>
            <select name="role" id="user-role" class="w-full px-5 py-4 border-2 rounded-xl focus:ring-4 focus:ring-blue-300 text-lg">
              <option value="kasir">Kasir</option>
              <option value="admin">Admin</option>
            </select>
          </div>
        </div>
        <div class="mt-10 flex gap-6 justify-center">
          <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-12 py-5 rounded-xl text-xl font-bold shadow-xl transition transform hover:scale-105">
            Tambah Pengguna
          </button>
          <button type="button" onclick="resetForm()" class="bg-gray-600 hover:bg-gray-700 text-white px-12 py-5 rounded-xl text-xl font-bold shadow-xl transition">
            Reset Form
          </button>
        </div>
      </form>
    </div>

    <div class="bg-white p-10 rounded-2xl shadow-2xl">
      <h3 class="text-2xl font-bold mb-8 text-gray-700">Daftar Pengguna Aktif</h3>
      <div class="overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
            <tr>
              <th class="p-6 font-bold text-lg">No</th>
              <th class="p-6 font-bold text-lg">Username</th>
              <th class="p-6 font-bold text-lg">Role</th>
              <th class="p-6 font-bold text-lg text-center">Aksi</th>
            </tr>
          </thead>
          <tbody>
            <% if (users == null || users.isEmpty()) { %>
              <tr><td colspan="4" class="text-center py-16 text-gray-500 text-xl">Belum ada pengguna</td></tr>
            <% } else {
                int no = 1;
                for (User u : users) { %>
              <tr class="border-b hover:bg-gray-50">
                <td class="p-6 text-lg"><%= no++ %></td>
                <td class="p-6 font-bold text-xl"><%= u.getUsername() %></td>
                <td class="p-6">
                  <span class="px-5 py-2 rounded-full text-white font-bold <%= "admin".equals(u.getRole()) ? "bg-purple-600" : "bg-blue-600" %>">
                    <%= u.getRole().toUpperCase() %>
                  </span>
                </td>
                <td class="p-6 text-center space-x-4">
                  <% if (u.getId() != currentUserId) { %>
                    <a href="UserServlet?action=delete&id=<%= u.getId() %>" 
                       onclick="return confirm('Yakin hapus pengguna <%= u.getUsername() %>?')"
                       class="bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-xl font-bold inline-block">Hapus</a>
                  <% } else { %>
                    <span class="text-gray-500 italic">Akun Anda</span>
                  <% } %>
                </td>
              </tr>
            <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <div id="toast"></div>

  <script>
    function resetForm() {
      document.querySelector('form').reset();
      document.getElementById('form-action').value = 'add';
      document.querySelector('button[type="submit"]').textContent = 'Tambah Pengguna';
    }

    function showToast(msg, type = 'success') {
      const toast = document.getElementById('toast');
      toast.textContent = msg;
      toast.className = type;
      toast.classList.add('show');
      setTimeout(() => toast.classList.remove('show'), 4000);
    }
  </script>
</body>
</html>