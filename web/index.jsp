<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Warung Bakso Pak Farrel - Login</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    *{font-family:'Poppins',sans-serif}
    body{background:linear-gradient(135deg,#1e3a8a 0%,#3b82f6 50%,#60a5fa 100%);overflow:hidden}
    .glass{backdrop-filter:blur(12px);background:rgba(255,255,255,0.15);border:1px solid rgba(255,255,255,0.2)}
    .input-glow:focus{box-shadow:0 0 20px rgba(59,130,246,0.5)}
    .btn-glow{background:linear-gradient(45deg,#3b82f6,#60a5fa);box-shadow:0 8px 32px rgba(59,130,246,0.4)}
    .btn-glow:hover{transform:translateY(-2px);box-shadow:0 12px 40px rgba(59,130,246,0.6)}
    @keyframes blob{0%,100%{transform:translate(0,0) rotate(0deg)}50%{transform:translate(30px,-30px) rotate(180deg)}}
    .animate-blob{animation:blob 7s infinite}
    .animation-delay-2000{animation-delay:2s}
    .animation-delay-4000{animation-delay:4s}
  </style>
</head>
<body class="flex items-center justify-center min-h-screen relative">
  <div class="absolute inset-0 overflow-hidden">
    <div class="absolute -top-40 -left-40 w-80 h-80 bg-purple-500 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob"></div>
    <div class="absolute -top-20 -right-20 w-80 h-80 bg-yellow-500 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-2000"></div>
    <div class="absolute -bottom-40 left-60 w-80 h-80 bg-pink-500 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-4000"></div>
  </div>

  <div class="glass p-8 rounded-2xl shadow-2xl w-full max-w-md z-10">
    <div class="text-center mb-8">
      <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full mb-4 animate-pulse">
        <svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h-4m-6 0H5a2 2 0 002-2v-1"></path>
        </svg>
      </div>
      <h1 class="text-3xl font-bold text-white">Warung Bakso Pak Farrel</h1>
      <p class="text-blue-200 mt-1">Sistem Kasir Modern</p>
    </div>

    <!-- Pesan Error/Sukses -->
    <% if (request.getAttribute("message") != null) { %>
      <p class="text-center mb-4 text-sm font-medium <%= request.getAttribute("messageType") %>">
        <%= request.getAttribute("message") %>
      </p>
    <% } %>

    <form action="LoginServlet" method="POST">
      <div class="space-y-5">
        <input type="text" name="username" required class="w-full p-3 bg-white bg-opacity-20 border border-white border-opacity-30 rounded-xl text-white placeholder-blue-200 input-glow focus:outline-none" placeholder="Username">
        <input type="password" name="password" required class="w-full p-3 bg-white bg-opacity-20 border border-white border-opacity-30 rounded-xl text-white placeholder-blue-200 input-glow focus:outline-none" placeholder="Kata Sandi">
        <button type="submit" class="w-full py-4 btn-glow text-white font-bold rounded-xl transition-all duration-300 hover:scale-105">
          Masuk
        </button>
      </div>
    </form>

    <p class="text-center text-blue-200 mt-6 text-sm">
      Belum punya akun? Hubungi Admin untuk registrasi.
    </p>
  </div>
</body>
</html>