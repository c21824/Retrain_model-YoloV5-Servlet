<%@ page import="Entity.Admin" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Home.jsp (functions centered + admin info top-right + greeting) --%>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Admin Home — PTHTTM</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

  <style>
    :root{
      --bg-1: #f8fbff;
      --card-bg: #ffffff;
      --accent-1: #2563eb;
      --accent-2: #7c3aed;
      --muted: #6b7280;
      --card-radius: 14px;
      --btn-radius: 12px;
    }

    *{box-sizing:border-box}
    html,body{height:100%}
    body{
      margin:0;
      font-family:"Inter",system-ui,-apple-system,"Segoe UI",Roboto,Arial;
      -webkit-font-smoothing:antialiased;
      -moz-osx-font-smoothing:grayscale;
      background:
              radial-gradient(1200px 500px at -10% 10%, rgba(37,99,235,0.06), transparent 12%),
              radial-gradient(900px 400px at 110% 90%, rgba(124,58,237,0.03), transparent 12%),
              var(--bg-1);
      color:#0f172a;
      display:flex;
      flex-direction:column;
      min-height:100vh;
    }

    .topbar{
      padding:14px 0;
      border-bottom:1px solid rgba(15,23,42,0.04);
      background:transparent;
    }
    .brand{ font-weight:700; font-size:1rem; letter-spacing:.2px; }
    .top-right { display:flex; align-items:center; gap:12px; }

    .admin-compact { text-align:right; margin-right:8px; }
    .admin-compact .name { font-weight:700; font-size:0.98rem; line-height:1; }
    .admin-compact .role { color:var(--muted); font-size:0.82rem; line-height:1; margin-top:4px; }
    .logout-btn { margin-left:8px; }

    .greeting-wrap {
      max-width:820px;
      margin:18px auto 6px;
      padding:0 18px;
      text-align:center;
    }
    .greeting {
      display:inline-block;
      padding:18px 22px;
      border-radius:12px;
      background: linear-gradient(180deg, rgba(255,255,255,0.9), rgba(255,255,255,0.98));
      box-shadow: 0 10px 30px rgba(12,20,40,0.06);
      border:1px solid rgba(226,232,240,0.6);
      min-width:280px;
    }
    .greeting h2 { margin:0; font-size:1.15rem; font-weight:700; }
    .greeting p { margin:6px 0 0; color:var(--muted); font-size:0.95rem; }

    .wrap {
      max-width:820px;
      margin:14px auto 40px;
      padding:0 18px;
      width:100%;
      display:flex;
      align-items:center;
      justify-content:center;
      flex:0 0 auto;
    }

    .card {
      width:100%;
      background: linear-gradient(180deg, rgba(255,255,255,0.98), var(--card-bg));
      border-radius:var(--card-radius);
      padding:22px;
      box-shadow: 0 18px 50px rgba(12,20,40,0.08);
      border: 1px solid rgba(226,232,240,0.6);
      text-align:center;
    }

    .card-title {
      font-weight:700;
      font-size:1.05rem;
      margin-bottom:12px;
    }

    .center-actions {
      display:flex;
      gap:18px;
      justify-content:center;
      align-items:center;
      flex-wrap:wrap;
      width:100%;
      margin-top:6px;
    }

    .action-btn {
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap:10px;
      min-width:260px;
      padding:14px 18px;
      border-radius:var(--btn-radius);
      background:linear-gradient(180deg,#ffffff,#fbfdff);
      border:1px solid rgba(14,165,233,0.06);
      font-weight:700;
      color:#0f172a;
      text-decoration:none;
      transition: transform .14s cubic-bezier(.2,.9,.2,1), box-shadow .14s ease;
      cursor:pointer;
      box-shadow: 0 8px 24px rgba(13,27,62,0.06);
    }
    .action-btn i { font-size:1.15rem; color:var(--accent-2); }
    .action-btn:hover { transform: translateY(-6px); box-shadow: 0 22px 50px rgba(12,20,40,0.10); }
    .action-btn:active { transform: translateY(-2px); }
    .action-btn:focus { outline: none; box-shadow: 0 0 0 4px rgba(37,99,235,0.12); border-color: var(--accent-1); }

    .action-sub { display:block; font-weight:500; color:var(--muted); font-size:.88rem; margin-top:12px; text-align:center; }

    @media (max-width:640px) {
      .action-btn{ min-width:100%; }
      .wrap{ padding:0 12px; margin:10px auto 30px; }
      .greeting { width:100%; box-sizing:border-box; }
    }
  </style>
</head>
<body>
<%
  Admin admin = (Admin) session.getAttribute("admin");
%>
<!-- Topbar -->
<nav class="topbar">
  <div class="container d-flex justify-content-between align-items-center" style="max-width:820px;">
    <div class="brand">Server AI Admin</div>

    <div class="top-right d-flex align-items-center">
      <div class="admin-compact">
        <div class="name"><%= admin.getFullName() %></div>
        <div class="role">Admin</div>
      </div>
      <a href="Login.jsp" class="btn btn-outline-secondary btn-sm logout-btn">Logout</a>
    </div>
  </div>
</nav>

<div class="greeting-wrap" aria-hidden="false">
  <div class="greeting" role="region" aria-label="Greeting">
    <h2>Hello, <%= admin.getFullName() %>!</h2>
    <p>Wellcome to adminstrator page - Select option to continue</p>
  </div>
</div>

<main class="wrap" role="main">
  <section class="card" aria-labelledby="functionsTitle">
    <div id="functionsTitle" class="card-title">Module</div>

    <div class="center-actions" role="navigation" aria-label="Quick actions">
      <a href="<%= request.getContextPath() %>/RetrainModel.jsp"
         id="btnRetrain" class="action-btn" title="Retrain Model" role="button">
        <i class="bi bi-arrow-repeat"></i>
        <span>Retrain Model</span>
      </a>

      <button id="btnManage" class="action-btn" title="Manage Samples / Labels (placeholder)">
        <i class="bi bi-folder-symlink"></i>
        <span>Manage Samples / Labels</span>
      </button>
    </div>
  </section>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>

</script>
</body>
</html>
