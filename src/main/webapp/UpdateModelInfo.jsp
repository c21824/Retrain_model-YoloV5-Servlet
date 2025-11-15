<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Entity.Admin" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="Entity.Model" %>
<%@ page import="org.apache.commons.lang3.StringEscapeUtils" %>

<%
  Admin admin = (Admin) session.getAttribute("admin");

  Map<String, Double> metrics = (Map<String, Double>) request.getAttribute("metrics");
  if (metrics == null) metrics = new HashMap<>();

  double precision = metrics.get("precision");
  double recall    = metrics.get("recall");
  double f1        = metrics.get("f1");
  double accuracy  = metrics.get("accuracy");

  Model model = (Model) session.getAttribute("model");
  String modelName = model.getName();
  String weights = (String) request.getAttribute("weights");

%>
<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Update Model Info — PTHTTM</title>

  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

  <style>
    :root{ --muted:#6b7280; --accent:#2563eb; --card-radius:12px; --border-weak: rgba(226,232,240,0.9); --input-width:240px; --form-max-width:720px; }
    html,body{height:100%}
    body{ margin:0; font-family:"Inter",system-ui,-apple-system,"Segoe UI",Roboto,Arial; -webkit-font-smoothing:antialiased; background: linear-gradient(180deg,#f8fbff 0%, #f3f7fb 100%); color:#0f172a; }
    .topbar { padding:14px 0; border-bottom:1px solid rgba(15,23,42,0.04); } .brand { font-weight:700; }
    .wrap { max-width:920px; margin:34px auto; padding:0 16px; }
    .card-page { background: linear-gradient(180deg,#ffffff,#fbfdff); border-radius: var(--card-radius); padding:18px; box-shadow: 0 18px 50px rgba(12,20,40,0.06); border:1px solid var(--border-weak); display:flex; flex-direction:column; gap:12px; }
    .card-header { display:flex; align-items:center; justify-content:center; gap:12px; margin:0; font-weight:700; font-size:1.15rem; }
    .form-grid { width:100%; max-width: var(--form-max-width); margin: 0 auto; border-radius:10px; overflow:hidden; border:1px solid rgba(226,232,240,0.8); background:#fbfdff; }
    .form-row { display:flex; gap:0; align-items:center; padding:12px 16px; border-bottom:1px solid rgba(226,232,240,0.8); }
    .form-row:last-child { border-bottom:0; }
    .col-label { flex:0 0 140px; font-weight:700; color:var(--muted); padding-right:14px; }
    .col-input { flex:1; display:flex; align-items:center; justify-content:flex-start; gap:12px; }
    .text-input, .percent-input { width: var(--input-width); padding:8px 10px; border-radius:10px; border:1px solid rgba(14,165,233,0.08); background:#fff; font-weight:700; box-shadow: inset 0 -1px 0 rgba(0,0,0,0.02); }
    .percent-wrap { display:flex; align-items:center; gap:8px; }
    .percent-suffix { color:var(--muted); font-weight:700; padding:6px 8px; border-radius:8px; background:transparent; }
    .card-footer-row { display:flex; justify-content:flex-end; gap:10px; align-items:center; padding-top:6px; border-top:1px solid rgba(226,232,240,0.7); }
    .position-fixed-topright { position: fixed; top: 16px; right: 16px; z-index:1200; }
    @media (max-width:780px){ :root { --input-width:100%; --form-max-width:100%; } .form-row { flex-direction:column; align-items:stretch; gap:8px; padding:10px; } .col-label { flex-basis:auto; padding-right:0; } .card-footer-row { justify-content:center; } }
  </style>
</head>

<body>
<nav class="topbar">
  <div class="container d-flex justify-content-between align-items-center" style="max-width:1100px;">
    <div class="brand">Server AI Admin</div>
    <div class="d-flex align-items-center gap-3">
      <div style="text-align:right;">
        <div style="font-weight:700;"><%= (admin!=null? admin.getFullName() : "Admin") %></div>
        <div class="small-muted">Admin</div>
      </div>
      <a href="Login.jsp" class="btn btn-outline-secondary btn-sm">Logout</a>
    </div>
  </div>
</nav>

<main class="wrap" role="main">
  <section class="card-page" aria-labelledby="pageTitle">
    <div id="pageTitle" class="card-header">Update Model Info Page</div>

    <div class="form-grid" role="form" aria-label="Update model values">
      <div class="form-row" style="background:linear-gradient(180deg,#f8fbff,#fff);font-weight:700;">
        <div class="col-label">Output</div>
        <div class="col-input">Value</div>
      </div>

      <div class="form-row">
        <div class="col-label">Model name</div>
        <div class="col-input">
          <input id="inpName" class="text-input" type="text"
                 value='<%= modelName %>' aria-label="Model name">
        </div>
      </div>

      <div class="form-row">
        <div class="col-label">Accuracy</div>
        <div class="col-input">
          <div class="percent-wrap">
            <input id="inpAccuracy" class="percent-input" type="number" step="0.01" min="0" max="100"
                   value='<%= String.format(java.util.Locale.US, "%.2f", accuracy) %>' aria-label="Accuracy">
            <div class="percent-suffix">%</div>
          </div>
        </div>
      </div>

      <div class="form-row">
        <div class="col-label">Precision</div>
        <div class="col-input">
          <div class="percent-wrap">
            <input id="inpPrecision" class="percent-input" type="number" step="0.01" min="0" max="100"
                   value='<%= String.format(java.util.Locale.US, "%.2f", precision) %>' aria-label="Precision">
            <div class="percent-suffix">%</div>
          </div>
        </div>
      </div>

      <div class="form-row">
        <div class="col-label">Recall</div>
        <div class="col-input">
          <div class="percent-wrap">
            <input id="inpRecall" class="percent-input" type="number" step="0.01" min="0" max="100"
                   value='<%= String.format(java.util.Locale.US, "%.2f", recall) %>' aria-label="Recall">
            <div class="percent-suffix">%</div>
          </div>
        </div>
      </div>

      <div class="form-row">
        <div class="col-label">F1</div>
        <div class="col-input">
          <div class="percent-wrap">
            <input id="inpF1" class="percent-input" type="number" step="0.01" min="0" max="100"
                   value='<%= String.format(java.util.Locale.US, "%.2f", f1) %>' aria-label="F1">
            <div class="percent-suffix">%</div>
          </div>
        </div>
      </div>
    </div>

    <div class="card-footer-row">
      <button id="btnCancel" class="btn btn-outline-secondary">Cancel</button>
      <button id="btnUpdate" class="btn btn-primary">Update model</button>
    </div>
  </section>
</main>

<!-- hidden fields for JS -->
<input type="hidden" id="modelId" value="<%= model.getId() %>">
<input type="hidden" id="weights" value="<%= StringEscapeUtils.escapeHtml4(weights) %>">

<div class="position-fixed-topright" id="toastRoot" aria-live="polite" aria-atomic="true"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
  const btnUpdate = document.getElementById('btnUpdate');
  const btnCancel = document.getElementById('btnCancel');
  // nút cancel
  btnCancel.addEventListener('click', () => {
    window.location.href = '<%= request.getContextPath() %>/RetrainModel.jsp';
  });
  // giúp hiển thị toast
  function showToast(title, message, variant='success', delay=3500) {
    const root = document.getElementById('toastRoot');
    const id = 't' + Date.now();
    const bg = variant === 'success' ? 'bg-success text-white' : (variant === 'danger' ? 'bg-danger text-white' : 'bg-dark text-white');
    const html = `
        <div id="${id}" class="toast ${bg}" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="${delay}">
          <div class="d-flex">
            <div class="toast-body">
              <strong>${title}</strong>
              <div style="opacity:.95; margin-top:6px;">${message}</div>
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
          </div>
        </div>
      `;
    root.insertAdjacentHTML('beforeend', html);
    const el = document.getElementById(id);
    const bs = new bootstrap.Toast(el);
    bs.show();
    el.addEventListener('hidden.bs.toast', () => el.remove());
  }
  // gửi thông tin update
  async function postUpdate(payload) {
    const url = '<%= request.getContextPath() %>/updateModel';
    btnUpdate.disabled = true;
    btnUpdate.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Updating...';
    try {
      const resp = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const text = await resp.text();
      let json = null;
      try { json = JSON.parse(text); } catch (e) {}

      if (resp.ok && json && json.success) {
        showToast('Updated', json.message || 'Model updated successfully.', 'success', 1600);
        const redirectTo = (json && json.redirect) ? json.redirect : '<%= request.getContextPath() %>/retrain.jsp';
        setTimeout(()=> window.location.href = redirectTo, 900);
      } else {
        const err = (json && json.message) ? json.message : text;
        showToast('Error', `Update failed: ${resp.status} ${err}`, 'danger', 7000);
      }
    } catch (err) {
      showToast('Error', `Network error: ${err.message}`, 'danger', 7000);
    } finally {
      btnUpdate.disabled = false;
      btnUpdate.innerHTML = 'Update model';
    }
  }
  //click nút vào udpate
  btnUpdate.addEventListener('click', () => {
    const payload = {
      model_id: parseInt(document.getElementById('modelId').value || '0', 10),
      name: document.getElementById('inpName').value || '',
      weights: document.getElementById('weights').value || '',
      accuracy: parseFloat(document.getElementById('inpAccuracy').value || '0'),
      precision: parseFloat(document.getElementById('inpPrecision').value || '0'),
      recall: parseFloat(document.getElementById('inpRecall').value || '0'),
      f1: parseFloat(document.getElementById('inpF1').value || '0')
    };
    postUpdate(payload);
  });
  // sử dụng nút enter
  ['inpName','inpAccuracy','inpPrecision','inpRecall','inpF1'].forEach(id=>{
    const el = document.getElementById(id);
    if (el) {
      el.addEventListener('keydown', function(e){
        if (e.key === 'Enter') { e.preventDefault(); btnUpdate.click(); }
      });
    }
  });
</script>
</body>
</html>
