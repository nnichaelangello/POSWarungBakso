<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.poswarungbakso.model.Product, com.poswarungbakso.model.Transaction, java.util.List, java.time.*, java.time.format.DateTimeFormatter" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Transaction> todayTransactions = (List<Transaction>) request.getAttribute("todayTransactions");
    Integer todayCount = (Integer) request.getAttribute("todayCount");
    Integer todayRevenue = (Integer) request.getAttribute("todayRevenue");
    String username = (String) request.getAttribute("username");
    String role = (String) request.getAttribute("role");
    String msg = request.getParameter("msg");

    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
    ZoneId zone = ZoneId.of("Asia/Jakarta");
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Transaksi Kasir - Warung Bakso Pak Farrel</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <style>
    .navbar-active{background:rgba(255,255,255,0.25)!important;font-weight:bold;border-radius:8px}
    #toast{position:fixed;bottom:30px;right:30px;padding:16px 32px;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.2);z-index:9999;font-weight:bold;opacity:0;transform:translateY(20px);transition:all .4s}
    #toast.show{opacity:1;transform:translateY(0)}
    #toast.success{background:#10b981;color:white}
    #toast.error{background:#ef4444;color:white}
    .product-card{transition:all 0.3s;cursor:pointer}
    .product-card:hover{transform:translateY(-8px) scale(1.05);box-shadow:0 20px 40px rgba(0,0,0,0.15)}
    .product-card.low-stock{border:4px solid #f59e0b}
    .product-card.out-stock{opacity:0.6;pointer-events:none;background:#fee2e2}
  </style>
</head>
<body class="bg-gray-100 min-h-screen">
  <!-- Navbar -->
  <nav class="bg-blue-700 text-white shadow-xl">
    <div class="container mx-auto px-4 py-4">
      <div class="flex justify-between items-center">
        <h1 class="text-2xl font-bold">Warung Bakso Pak Farrel</h1>
        <div class="hidden md:flex items-center space-x-1">
          <a href="TransactionServlet" class="px-5 py-3 rounded-lg navbar-active transition">Transaksi</a>
          <a href="../index.jsp" class="bg-red-600 hover:bg-red-700 px-6 py-3 rounded-lg font-bold ml-4 transition">Keluar</a>
        </div>
      </div>
    </div>
  </nav>

  <div class="container mx-auto px-4 py-8 max-w-7xl">
    <h2 class="text-4xl font-bold text-center text-gray-800 mb-10">Sistem Kasir POS Profesional</h2>

    <% if ("success".equals(msg)) { %>
      <script>showToast("Transaksi berhasil disimpan!", "success")</script>
    <% } else if ("error".equals(msg) || "stock".equals(msg) || "empty".equals(msg)) { %>
      <script>showToast("Gagal transaksi! Stok tidak cukup atau keranjang kosong.", "error")</script>
    <% } %>

    <div class="grid grid-cols-1 xl:grid-cols-3 gap-8">
      <!-- Kiri: Produk & Keranjang -->
      <div class="xl:col-span-2 space-y-8">
        <!-- Search -->
        <div class="bg-white p-6 rounded-2xl shadow-2xl">
          <input type="text" id="search-product" class="w-full px-5 py-4 border-2 rounded-xl focus:ring-4 focus:ring-blue-300 text-lg" placeholder="Cari nama / kode..." onkeyup="filterProducts()">
        </div>

        <!-- Grid Produk -->
        <div class="bg-white p-8 rounded-2xl shadow-2xl">
          <h3 class="text-2xl font-bold text-gray-800 mb-6">Pilih Produk</h3>
          <div id="product-grid" class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-6">
            <% for (Product p : products) {
                boolean low = p.getStock() < 10 && p.getStock() > 0;
                boolean isOutOfStock = p.getStock() == 0;
            %>
              <div class="product-card bg-white rounded-2xl shadow-xl p-6 text-center <%= low ? "low-stock" : "" %> <%= isOutOfStock ? "out-stock" : "" %>"
                   <%= isOutOfStock ? "" : "onclick=\"addToCart('" + p.getCode() + "')\"" %>>
                <div class="text-5xl mb-3">🍲</div>
                <h4 class="font-bold text-xl"><%= p.getName() %></h4>
                <p class="text-gray-600 text-sm"><%= p.getCode() %></p>
                <p class="text-3xl font-extrabold text-green-600 mt-3">Rp <%= String.format("%,d", p.getPrice()) %></p>
                <p class="text-lg font-bold mt-2 <%= isOutOfStock ? "text-red-600" : low ? "text-orange-600" : "text-green-600" %>">
                  Stok: <%= p.getStock() %>
                </p>
              </div>
            <% } %>
          </div>
        </div>

        <!-- Keranjang -->
        <div class="bg-white p-8 rounded-2xl shadow-2xl">
          <div class="flex justify-between items-center mb-6">
            <h3 class="text-2xl font-bold text-gray-800">Keranjang Belanja</h3>
            <button type="button" onclick="clearCart()" class="text-red-600 hover:underline font-bold">Kosongkan</button>
          </div>
          <form id="checkout-form" action="TransactionServlet" method="post">
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead class="bg-gradient-to-r from-blue-600 to-purple-600 text-white">
                  <tr>
                    <th class="p-4 text-left">Produk</th>
                    <th class="p-4 text-right">Harga</th>
                    <th class="p-4 text-center">Qty</th>
                    <th class="p-4 text-right">Subtotal</th>
                    <th class="p-4 text-center">Hapus</th>
                  </tr>
                </thead>
                <tbody id="cart-items"></tbody>
              </table>
            </div>
            <div class="mt-8 border-t-4 border-green-600 pt-6 bg-gradient-to-r from-green-50 to-emerald-50 p-6 rounded-xl">
              <div class="text-3xl font-bold text-right">
                <div id="total-bayar" class="text-4xl text-green-600">Rp 0</div>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4 mt-8">
              <button type="button" onclick="printReceipt()" class="bg-blue-600 hover:bg-blue-700 text-white py-6 rounded-xl text-3xl font-bold shadow-2xl">STRUK</button>
              <button type="button" onclick="checkout()" class="bg-green-600 hover:bg-green-700 text-white py-6 rounded-xl text-3xl font-bold shadow-2xl">BAYAR</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Kanan: Statistik & Riwayat -->
      <div class="space-y-8">
        <div class="bg-gradient-to-br from-blue-600 to-purple-700 text-white p-8 rounded-2xl shadow-2xl">
          <h3 class="text-2xl font-bold mb-6">Hari Ini</h3>
          <div class="space-y-6 text-2xl">
            <div class="flex justify-between"><span>Transaksi</span><span class="text-3xl font-extrabold"><%= todayCount %></span></div>
            <div class="flex justify-between"><span>Pendapatan</span><span class="text-3xl font-extrabold">Rp <%= String.format("%,d", todayRevenue) %></span></div>
          </div>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-2xl">
          <h3 class="text-xl font-bold mb-4">Riwayat Transaksi Hari Ini</h3>
          <div class="space-y-3 max-h-96 overflow-y-auto">
            <% if (todayTransactions.isEmpty()) { %>
              <p class="text-center text-gray-500 py-10">Belum ada transaksi hari ini</p>
            <% } else {
                for (Transaction t : todayTransactions) {
                    Instant instant = Instant.ofEpochMilli(t.getDate());
                    LocalDateTime ldt = LocalDateTime.ofInstant(instant, zone);
            %>
              <div class="flex justify-between items-center p-4 bg-gray-50 rounded-xl hover:bg-gray-100 transition">
                <div>
                  <div class="font-bold text-lg">#<%= t.getTransactionCode() %></div>
                  <div class="text-sm text-gray-600"><%= timeFmt.format(ldt) %></div>
                </div>
                <div class="text-right">
                  <div class="font-bold text-2xl text-green-600">Rp <%= String.format("%,d", t.getTotal()) %></div>
                </div>
              </div>
            <% } } %>
          </div>
        </div>
      </div>
    </div>

    <div id="toast"></div>

    <script>
      let cart = [];

      const productMap = {
        <% for (Product p : products) { %>
          '<%= p.getCode() %>': { name: '<%= p.getName() %>', price: <%= p.getPrice() %>, stock: <%= p.getStock() %> },
        <% } %>
      };

      function addToCart(code) {
        const p = productMap[code];
        if (!p || p.stock <= 0) {
          showToast('Stok habis!', 'error');
          return;
        }
        const existing = cart.find(item => item.code === code);
        if (existing) {
          if (existing.quantity >= p.stock) {
            showToast('Stok tidak cukup!', 'error');
            return;
          }
          existing.quantity++;
        } else {
          cart.push({ code: code, name: p.name, price: p.price, quantity: 1 });
        }
        renderCart();
      }

      function renderCart() {
        const tbody = document.getElementById('cart-items');
        let html = '';
        let total = 0;
        cart.forEach((item, index) => {
          const subtotal = item.price * item.quantity;
          total += subtotal;
          html += '<tr class="border-b">' +
            '<td class="p-4 font-bold">' + item.name + '</td>' +
            '<td class="p-4 text-right">Rp ' + item.price.toLocaleString('id-ID') + '</td>' +
            '<td class="p-4 text-center">' +
              '<div class="flex items-center justify-center gap-3">' +
                '<button type="button" onclick="updateQty(' + index + ', -1)" class="bg-red-500 hover:bg-red-600 text-white w-10 h-10 rounded-full font-bold">-</button>' +
                '<input type="hidden" name="code" value="' + item.code + '">' +
                '<input type="hidden" name="quantity" value="' + item.quantity + '">' +
                '<span class="text-2xl font-bold w-16 text-center">' + item.quantity + '</span>' +
                '<button type="button" onclick="updateQty(' + index + ', 1)" class="bg-green-500 hover:bg-green-600 text-white w-10 h-10 rounded-full font-bold">+</button>' +
              '</div>' +
            '</td>' +
            '<td class="p-4 text-right font-bold text-xl">Rp ' + subtotal.toLocaleString('id-ID') + '</td>' +
            '<td class="p-4 text-center"><button type="button" onclick="removeFromCart(' + index + ')" class="text-red-600 text-3xl font-bold">×</button></td>' +
            '</tr>';
        });
        if (cart.length === 0) {
          html = '<tr><td colspan="5" class="text-center py-20 text-gray-500 text-2xl">Keranjang kosong</td></tr>';
        }
        tbody.innerHTML = html;
        document.getElementById('total-bayar').textContent = 'Rp ' + total.toLocaleString('id-ID');
      }

      function updateQty(index, change) {
        const item = cart[index];
        const p = productMap[item.code];
        const newQty = item.quantity + change;
        if (newQty < 1) {
          removeFromCart(index);
          return;
        }
        if (newQty > p.stock) {
          showToast('Stok tidak cukup!', 'error');
          return;
        }
        cart[index].quantity = newQty;
        renderCart();
      }

      function removeFromCart(index) {
        cart.splice(index, 1);
        renderCart();
      }

      function clearCart() {
        if (confirm('Kosongkan keranjang?')) {
          cart = [];
          renderCart();
        }
      }

      function checkout() {
        if (cart.length === 0) {
          showToast('Keranjang kosong!', 'error');
          return;
        }
        if (confirm('Selesaikan transaksi ini?')) {
          document.getElementById('checkout-form').submit();
        }
      }

      function printReceipt() {
        if (cart.length === 0) {
          showToast('Keranjang kosong!', 'error');
          return;
        }
        let total = cart.reduce((sum, i) => sum + i.price * i.quantity, 0);
        let itemsHtml = '';
        cart.forEach(i => {
          itemsHtml += i.name + ' x ' + i.quantity + ' @ Rp ' + i.price.toLocaleString('id-ID') + ' = Rp ' + (i.price * i.quantity).toLocaleString('id-ID') + '<br>';
        });
        const win = window.open('', '_blank');
        win.document.write('<html><head><title>Struk Preview</title><style>body{font-family:sans-serif;padding:40px;text-align:center;}</style></head><body>' +
          '<h1>Warung Bakso Pak Farrel</h1><hr>' +
          '<h2>STRUK PREVIEW</h2>' +
          '<p>' + itemsHtml + '</p><hr>' +
          '<h2>TOTAL: Rp ' + total.toLocaleString('id-ID') + '</h2>' +
          '<p>Terima kasih!</p></body></html>');
        win.print();
      }

      function filterProducts() {
        const search = document.getElementById('search-product').value.toLowerCase();
        const cards = document.querySelectorAll('.product-card');
        cards.forEach(card => {
          const name = card.querySelector('h4').textContent.toLowerCase();
          const code = card.querySelector('p.text-gray-600').textContent.toLowerCase();
          card.style.display = (name.includes(search) || code.includes(search)) ? 'block' : 'none';
        });
      }

      function showToast(msg, type = 'success') {
        const toast = document.getElementById('toast');
        toast.textContent = msg;
        toast.className = type;
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 4000);
      }

      // Inisialisasi
      renderCart(); // kosong awalnya
    </script>
  </body>
</html>