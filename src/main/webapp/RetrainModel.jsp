<%@ page import="Entity.Admin" %>
<%@ page import="java.util.Set" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
    Set<String> sessionSelected = (Set<String>) session.getAttribute("selectedSampleIds");
    if(sessionSelected != null){
        session.removeAttribute("selectedSampleIds");
    }
%>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Retrain Model — PTHTTM</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet"/>

    <style>
        :root {
            --muted: #6b7280;
            --accent: #2563eb;
            --card-radius: 12px;
            --table-border: #e6eefc;
        }

        body {
            font-family: "Inter", system-ui;
            background: #f6fafc;
            color: #0f172a;
            margin: 0;
        }

        .wrap {
            max-width: 960px;
            margin: 28px auto;
            padding: 0 16px;
        }

        .panel-card {
            background: #fff;
            border-radius: var(--card-radius);
            padding: 22px;
            box-shadow: 0 10px 28px rgba(12, 20, 40, 0.06);
            border: 1px solid rgba(226, 232, 240, 0.7);
        }

        .controls {
            display: flex;
            gap: 10px;
            align-items: center;
            justify-content: center;
            flex-wrap: wrap;
            margin-bottom: 18px;
        }

        .table-center {
            display: flex;
            justify-content: center;
            margin: 8px 0 18px;
        }

        .metrics {
            min-width: 300px;
            max-width: 560px;
            width: 100%;
        }

        .metrics-box {
            border-radius: 10px;
            border: 1px solid var(--table-border);
            padding: 6px;
            background: linear-gradient(180deg, #fff, #fbfdff);
        }

        .metrics-table {
            margin: 0;
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 8px;
        }

        .metrics-table tbody tr {
            background: #fff;
            border-radius: 8px;
            box-shadow: inset 0 -1px 0 rgba(0, 0, 0, 0.02);
        }

        .metrics-table td, .metrics-table th {
            padding: 12px 14px;
            vertical-align: middle;
        }

        .metrics-table th {
            width: 160px;
            color: var(--muted);
            font-weight: 700;
            border: 0;
        }

        .metrics-table td {
            font-weight: 600;
            border: 0;
            text-align: left;
        }

        .bottom-actions {
            display: flex;
            justify-content: center;
            gap: 12px;
            margin-top: 18px;
        }

        #metricsContainer, #bottomActions {
            display: none;
        }

        @media (max-width: 720px) {
            .controls {
                flex-direction: column;
            }

            .bottom-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<nav style="padding:14px 0; border-bottom:1px solid rgba(15,23,42,0.04);">
    <div class="container" style="max-width:960px; display:flex; justify-content:space-between; align-items:center;">
        <div style="font-weight:700;">Server AI Admin</div>
        <div style="display:flex; align-items:center; gap:12px;">
            <div style="text-align:right;">
                <div style="font-weight:700;"><%= admin != null ? admin.getFullName() : "Unknown" %>
                </div>
                <div style="color:var(--muted); font-size:.88rem;">Admin</div>
            </div>
            <a href="Login.jsp" class="btn btn-outline-secondary btn-sm">Logout</a>
        </div>
    </div>
</nav>

<main class="wrap">
    <div class="panel-card">
        <h3 style="text-align:center; margin-bottom:16px; font-weight:800;" aria-label="Greeting">Retrain Model Page</h3>

        <div class="controls" role="form" aria-label="Select model to load metrics">
            <button id="btnBack" class="btn btn-outline-secondary"><i class="bi bi-arrow-left me-1"></i> Back</button>
            <select id="modelSelect" class="form-select" style="max-width:240px;">
                <option value="">-- Chọn model --</option>
                <option value="1">Detect1</option>
                <option value="2">Detect2</option>
            </select>

            <button id="btnSelectModel" class="btn btn-primary" aria-live="polite">
                <span id="btnText">Select model</span>
                <span id="btnSpinner" class="spinner-border spinner-border-sm ms-2" role="status" aria-hidden="true"
                      style="display:none;"></span>
            </button>
        </div>

        <!-- hidden until model loaded -->
        <div id="metricsContainer" class="table-center" aria-hidden="true">
            <div class="metrics">
                <div class="metrics-box" role="region" aria-label="Model metrics">
                    <table class="metrics-table mb-0" id="metricsTable">
                        <tbody>
                        <tr>
                            <th scope="row">Model name</th>
                            <td id="m_name"></td>
                        </tr>
                        <tr>
                            <th scope="row">Update date</th>
                            <td id="m_updateDate"></td>
                        </tr>
                        <tr>
                            <th scope="row">Accuracy</th>
                            <td id="m_accuracy"></td>
                        </tr>
                        <tr>
                            <th scope="row">Precision</th>
                            <td id="m_precision"></td>
                        </tr>
                        <tr>
                            <th scope="row">Recall</th>
                            <td id="m_recall"></td>
                        </tr>
                        <tr>
                            <th scope="row">F1</th>
                            <td id="m_f1"></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div id="bottomActions" class="bottom-actions">
            <a id="btnSelectSample" class="btn btn-outline-primary" href="#" role="button">Select sample</a>
        </div>
    </div>
</main>

<script>
    const sel = document.getElementById('modelSelect');
    const btn = document.getElementById('btnSelectModel');
    const btnText = document.getElementById('btnText');
    const btnSpinner = document.getElementById('btnSpinner');
    const metricsContainer = document.getElementById('metricsContainer');
    const bottomActions = document.getElementById('bottomActions');

    // hiển thị trạng thái trên nút select model
    function showLoading(show) {
        if (show) {
            btnSpinner.style.display = '';
            btn.setAttribute('disabled', 'disabled');
            btnText.textContent = 'Loading...';
        } else {
            btnSpinner.style.display = 'none';
            btn.removeAttribute('disabled');
            btnText.textContent = 'Select model';
        }
    }

    //hiển thị thông tin model m trên DOM
    function renderModel(m) {
        document.getElementById('m_name').textContent = m.name || '-';
        document.getElementById('m_updateDate').textContent = m.updateDate || '-';
        document.getElementById('m_accuracy').textContent = m.accuracy || '-';
        document.getElementById('m_precision').textContent = m.precision || '-';
        document.getElementById('m_recall').textContent = m.recall || '-';
        document.getElementById('m_f1').textContent = m.f1 || '-';
    }

    //lấy dữ liệu model từ fetchAPI
    async function fetchModelById(id) {
        const url = '<%= request.getContextPath() %>/model?id=' + encodeURIComponent(id);
        const resp = await fetch(url, {
            method: 'GET',
            credentials: 'same-origin'
        });
        if (!resp.ok) throw new Error('Server returned ' + resp.status);
        return resp.json();
    }

    //người dùng khi bấm select model
    btn.addEventListener('click', async function (e) {
        e.preventDefault();
        const id = sel.value;
        if (!id) {
            alert('Select 1 model before click Select model.');
            sel.focus();
            return;
        }

        showLoading(true);
        try {
            const model = await fetchModelById(id);
            renderModel(model);
            onModelLoaded(id);
            metricsContainer.style.display = 'flex';
            metricsContainer.setAttribute('aria-hidden', 'false');
            bottomActions.style.display = 'flex';
            metricsContainer.scrollIntoView({behavior: 'smooth', block: 'center'});
        } catch (err) {
            console.error(err);
            alert('Cannot find model infomation: ' + err.message);
        } finally {
            showLoading(false);
        }
    });

    // gán cho nút back
    document.getElementById('btnBack').addEventListener('click', function (e) {
        e.preventDefault();
        if (window.history.length > 1) window.history.back();
        else window.location.href = '<%= request.getContextPath() %>/home.jsp';
    });

    // Có thể dùng enter thay cho click
    sel.addEventListener('keydown', function (ev) {
        if (ev.key === 'Enter') {
            ev.preventDefault();
            btn.click();
        }
    });
    const btnSelectSample = document.getElementById('btnSelectSample');

    //gửi id của model sang cho /retrain
    function buildRetrainUrl(id) {
        const ctx = '<%= request.getContextPath() %>';
        return ctx + '/retrain?id=' + encodeURIComponent(id);
    }

    //load nút select sample
    function onModelLoaded(id) {
        btnSelectSample.setAttribute('href', buildRetrainUrl(id));
        btnSelectSample.classList.remove('disabled');
        btnSelectSample.removeAttribute('aria-disabled');
    }

    // ngăn chặn việc select sample khi chưa chọn model
    btnSelectSample.addEventListener('click', function (e) {
        const href = btnSelectSample.getAttribute('href') || '';
        if (!href || href === '#' || metricsContainer.style.display === 'none') {
            e.preventDefault();
            sel.focus();
            return;
        }
    });
</script>
</body>
</html>
