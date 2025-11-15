<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="false" %>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Admin Login</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

  <style>
    :root{
      --accent: #3b82f6;
      --card-radius: 14px;
      --surface: #ffffff;
      --muted: #6b7280;
    }
    html,body { height:100%; }
    body {
      margin:0;
      font-family: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
      background: linear-gradient(180deg, rgba(59,130,246,0.06) 0%, rgba(99,102,241,0.02) 100%), #f6fafc;
      -webkit-font-smoothing:antialiased;
      -moz-osx-font-smoothing:grayscale;
    }

    .auth-wrap {
      min-height:100vh;
      display:flex;
      align-items:center;
      justify-content:center;
      padding:32px;
    }

    .auth-card {
      width:100%;
      max-width:520px;
      background: var(--surface);
      border-radius: var(--card-radius);
      box-shadow: 0 10px 30px rgba(16,24,40,0.08);
      overflow:hidden;
      transform: translateY(6px);
      transition: transform .28s ease, box-shadow .28s ease;
    }
    .auth-card:hover { transform: translateY(0); box-shadow: 0 18px 45px rgba(16,24,40,0.12); }

    .auth-brand {
      padding:28px 28px 18px 28px;
      display:flex;
      gap:14px;
      align-items:center;
      border-bottom: 1px solid #f1f5f9;
    }
    .logo {
      width:56px;
      height:56px;
      border-radius:12px;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      background: linear-gradient(135deg,var(--accent), #6366f1);
      color:#fff;
      font-weight:700;
      box-shadow: 0 6px 18px rgba(59,130,246,0.16);
      flex-shrink:0;
    }
    .brand-title { font-weight:600; font-size:1.05rem; margin:0; }
    .brand-sub { color:var(--muted); font-size:0.86rem; margin:0; }

    .auth-body { padding:28px; }

    label.form-label { font-size:0.92rem; font-weight:600; color:#111827; }
    .form-control {
      border-radius:10px;
      padding:12px 14px;
      box-shadow:none;
      border:1px solid #e6eef6;
    }
    .input-group .form-control { border-radius:10px 0 0 10px; }
    .input-icon {
      width:44px;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      background:#fbfdff;
      border:1px solid #e6eef6;
      border-left:1px solid #e6eef6;
      border-radius:0 10px 10px 0;
    }

    .btn-primary {
      --bs-btn-bg: var(--accent);
      --bs-btn-border-color: var(--accent);
      border-radius:10px;
      padding:10px 14px;
      font-weight:600;
      box-shadow: 0 8px 20px rgba(59,130,246,0.12);
    }

    .muted { color:var(--muted); font-size:.88rem; }

    .footer-note { padding:14px 28px; border-top:1px solid #f1f5f9; font-size:0.85rem; color:var(--muted); display:flex; justify-content:space-between; align-items:center; }

    @media (max-width:420px){
      .auth-card { border-radius:12px; margin:8px; }
      .logo { width:48px; height:48px; }
    }

  </style>
</head>
<body>
<div class="auth-wrap">
  <div class="auth-card">

    <div class="auth-brand">
      <div class="logo" aria-hidden="true">
        <i class="bi bi-shield-lock-fill" style="font-size:20px;"></i>
      </div>
      <div>
        <p class="brand-title">Manage Server AI — Admin</p>
        <p class="brand-sub">Login</p>
      </div>
    </div>

    <div class="auth-body">

      <% String error = (String) request.getAttribute("error"); %>
      <% if (error != null && !error.isEmpty()) { %>
      <div class="alert alert-danger py-2" role="alert"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(error) %></div>
      <% } %>

      <form method="post" action="<%= request.getContextPath() %>/login" novalidate>
        <div class="mb-3">
          <label for="username" class="form-label">Username</label>
          <div class="input-group">
            <span class="input-group-text bg-white border-end-0" id="u-icon"><i class="bi bi-person-fill"></i></span>
            <input id="username" name="username" class="form-control border-start-0" required
                   value="<%= request.getParameter("username") == null ? "" : request.getParameter("username") %>"
                   aria-describedby="u-icon" autocomplete="username" autofocus>
          </div>
        </div>

        <div class="mb-4">
          <label for="password" class="form-label">Password</label>
          <div class="input-group">
            <input id="password" name="password" type="password" class="form-control" required
                   aria-describedby="pwd-toggle" autocomplete="current-password">
            <button type="button" id="pwd-toggle" class="btn btn-outline-secondary input-icon" title="Hiện/ẩn mật khẩu" aria-label="Hiện hoặc ẩn mật khẩu">
              <i class="bi bi-eye" id="pwd-icon" aria-hidden="true"></i>
            </button>
          </div>
        </div>

        <div class="d-grid mb-2">
          <button type="submit" class="btn btn-primary">Login</button>
        </div>
      </form>
    </div>

    <div class="footer-note">
      <div class="muted">© <span id="year"></span> Manage Server AI</div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
  (function () {
    const pwdInput = document.getElementById('password');
    const pwdToggle = document.getElementById('pwd-toggle');
    const pwdIcon = document.getElementById('pwd-icon');

    pwdToggle.addEventListener('click', function () {
      const type = pwdInput.type === 'password' ? 'text' : 'password';
      pwdInput.type = type;
      pwdIcon.className = type === 'password' ? 'bi bi-eye' : 'bi bi-eye-slash';
    });

    const yearEl = document.getElementById('year');
    if (yearEl) yearEl.textContent = new Date().getFullYear();

    const form = document.querySelector('form');
    form.addEventListener('submit', function (e) {
      const u = document.getElementById('username').value.trim();
      const p = document.getElementById('password').value.trim();
      if (!u || !p) {
        e.preventDefault();
        alert('Please enter username and password');
      }
    });
  })();
</script>
</body>
</html>
