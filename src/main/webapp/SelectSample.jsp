<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.text.SimpleDateFormat, java.util.Set, java.util.HashSet, java.util.StringJoiner, Entity.Sample, Entity.Model, Entity.Admin" %>
<%
    Admin admin = (Admin) session.getAttribute("admin");
//    các sample hiển thị trên page
    List<Sample> sampleList = (List<Sample>) request.getAttribute("sampleList");
    if (sampleList == null) sampleList = new java.util.ArrayList<>();
//    lấy số trang hiện tại và kích thước trang
    Integer pageObj = (Integer) request.getAttribute("page");
    int pageNum = (pageObj == null) ? 1 : pageObj.intValue();
    Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
    int pageSize = (pageSizeObj == null) ? 5 : pageSizeObj.intValue();
//    tổng số mẫu hiển thị và toàn bộ mẫu
    Integer reqTotal = (Integer) request.getAttribute("currentTotalCount");
    Integer sessionTotal = (Integer) session.getAttribute("totalCount");

    int totalCount;
    if (reqTotal != null) {
        totalCount = reqTotal.intValue();
    } else if (sessionTotal != null) {
        totalCount = sessionTotal.intValue();
    } else {
        totalCount = sampleList.size();
    }

    int totalPages = (int) Math.ceil(totalCount / (double) pageSize);
    if (totalPages < 1) totalPages = 1;
    if (pageNum < 1) pageNum = 1;
    if (pageNum > totalPages) pageNum = totalPages;

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    int startIndex = (pageNum - 1) * pageSize;

    Model model = (Model) session.getAttribute("model");
    String modelIdStr = (model != null) ? String.valueOf(model.getId()) : (request.getParameter("id") == null ? "" : request.getParameter("id"));

    String nameImgParam = request.getParameter("nameImg");
    if (nameImgParam == null) nameImgParam = "";

    Set<String> sessionSelectedSet = (Set<String>) session.getAttribute("selectedSampleIds");
    if (sessionSelectedSet == null) sessionSelectedSet = new java.util.HashSet<>();

%>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Select Sample — PTHTTM</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        :root{
            --muted: #6b7280;
            --card-radius: 12px;
            --accent: #2563eb;
            --panel-max-w: 1100px;
            --topbar-h: 64px;
        }
        html,body { height:100%; }
        body{
            font-family: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, Arial;
            background: #f6fafc;
            color: #0f172a;
            margin: 0;
            -webkit-font-smoothing:antialiased;
            font-size: 16px;
        }

        .topbar { height: var(--topbar-h); padding: 12px 0; border-bottom:1px solid rgba(15,23,42,0.04); background: transparent; }
        .brand { font-weight:800; font-size:1.05rem; }

        .container-main { display:flex; align-items:center; justify-content:center; min-height: calc(100vh - var(--topbar-h)); padding: 24px 16px; }

        .panel { background: #fff; padding:20px 26px; border-radius: var(--card-radius); box-shadow: 0 18px 40px rgba(16,24,40,0.10); border:1px solid rgba(226,232,240,0.85); max-width: var(--panel-max-w); width: 100%; transform: translateY(0); }

        .panel-head { display:flex; gap:16px; align-items:center; justify-content:space-between; flex-wrap:wrap; margin-bottom:10px; }

        .controls-left { display:flex; gap:10px; align-items:center; }

        .search-box { min-width:320px; font-size:0.98rem; padding:8px 10px; }
        .btn-sm { font-weight:700; padding:.45rem .6rem; }

        .table-wrap { position:relative; max-height:52vh; overflow:auto; }

        table.custom-table thead th { background: #f3f7ff; border-bottom: 1px solid rgba(226,232,240,0.9); font-weight:800; color:#0b1220; font-size:.98rem; position:sticky; top:0; z-index:2; }
        table.custom-table tbody tr { background: #fff; }
        table.custom-table tbody tr:hover { background: #fbfdff; }
        .small-muted { color:var(--muted); font-size:.95rem; }

        table.custom-table td { font-size: .98rem; color: #0b1220; }
        .action-col { width:120px; text-align:center; }

        h5.page-title { margin:0 0 4px 0; font-size:1.25rem; font-weight:800; letter-spacing: -0.2px; }

        .bottom-row { display:flex; justify-content:space-between; align-items:center; gap:12px; margin-top:16px; flex-wrap:wrap; }
        .bottom-left { display:flex; gap:10px; align-items:center; }
        .bottom-right { display:flex; gap:12px; align-items:center; }
        .badge-selected { font-weight:800; color:var(--accent); font-size:1.02rem; }

        .toast-container-top { position: fixed; top: 16px; right: 16px; z-index: 1080; }

        .pagination-wrap { display:flex; justify-content:center; margin-top:12px; }

        @media (max-width:900px){
            .panel-head { flex-direction:column; align-items:stretch; gap:10px; }
            .controls-left { width:100%; justify-content:flex-start; }
            .search-box { min-width:100%; }
            .bottom-row { flex-direction:column-reverse; align-items:stretch; }
            .bottom-right { justify-content:flex-end; }
        }
    </style>
</head>
<body>
<nav class="topbar">
    <div class="container d-flex justify-content-between align-items-center" style="max-width:1100px;">
        <div class="brand">Server AI Admin</div>
        <div class="d-flex align-items-center gap-3">
            <div style="text-align:right;">
                <div style="font-weight:800;"><%= (admin != null ? admin.getFullName() : "Quang Cuong") %></div>
                <div class="small-muted">Admin</div>
            </div>
            <a href="Login.jsp" class="btn btn-outline-secondary btn-sm">Logout</a>
        </div>
    </div>
</nav>

<main class="container-main" role="main">
    <div class="panel" role="region" aria-label="Select sample panel">

        <!-- Form chính: gửi GET về /retrain, kèm id, page, pageSize, nameImg và selectedIds (JS fill hidden inputs) -->
        <form id="searchForm" method="post" action="<%= request.getContextPath() + "/retrain" %>">
            <input type="hidden" name="id" value="<%= modelIdStr %>" />
            <input type="hidden" name="page" id="pageInput" value="<%= pageNum %>" />
            <input type="hidden" name="pageSize" id="pageSizeInput" value="<%= pageSize %>" />
            <input type="hidden" name="selectionMode" id="selectionMode" value="<%= (request.getAttribute("selectionMode") != null ? request.getAttribute("selectionMode") : "") %>" />

            <div class="panel-head">
                <div>
                    <h5 class="page-title">Select Sample Page</h5>
                    <div class="small-muted">Choose samples to include in retraining for model: <strong><%= (model!=null? model.getName() : "—") %></strong></div>
                </div>

                <div class="d-flex flex-column align-items-end gap-1">
                    <div class="d-flex align-items-center gap-2">
                        <input id="searchInput" name="nameImg" class="form-control form-control-sm search-box" type="search"
                               placeholder="Image name" aria-label="Search" value="<%= nameImgParam %>">
                        <!-- reset page to 1 when searching -->
                        <!-- đổi sang type=button: chúng ta sẽ gọi saveSelectionSnapshot() rồi redirect GET để tránh vô tình trigger retrain POST -->
                        <button id="btnSearch" type="button" class="btn btn-primary btn-sm">Search</button>
                    </div>
                </div>
            </div>

            <div style="display:flex; align-items:center; gap:12px; margin-bottom:10px;">
                <div class="controls-left">
                    <div class="form-check" title="Select all">
                        <input class="form-check-input" type="checkbox" id="selectAll">
                        <label class="form-check-label small-muted" for="selectAll" style="font-weight:700; margin-left:6px;">Select all (all matches)</label>
                    </div>

                    <button id="btnClearTop" class="btn btn-link btn-sm" type="button" style="font-weight:700; color:var(--muted);">Clear selection</button>
                </div>
            </div>

            <div class="table-wrap">
                <div class="table-responsive">
                    <table class="table table-sm custom-table align-middle">
                        <thead>
                        <tr>
                            <th style="width:44px;"></th>
                            <th style="width:54px;">#</th>
                            <th>Image name</th>
                            <th>Create date</th>
                            <th>Path</th>
                            <th>Type</th>
                        </tr>
                        </thead>
                        <tbody id="sampleTbody">
                        <%
                            for (int i = 0; i < sampleList.size(); i++) {
                                Sample s = sampleList.get(i);
                                String createDateStr = "";
                                int showId = s.getId();
                                if (model.getId() == 1) { // model id 1 là model mặc định, trừ 25 để hiển thị đúng id gốc
                                    showId -= 25;
                                }
                                else showId -= 6390;
                                if (s.getCreateDate() != null) {
                                    createDateStr = sdf.format(s.getCreateDate());
                                }
                                String sidStr = String.valueOf(s.getId());
                                boolean checked = sessionSelectedSet.contains(sidStr);
                        %>
                        <tr>
                            <td>
                                <input class="row-check form-check-input" type="checkbox" value="<%= sidStr %>" <%= checked ? "checked" : "" %> />
                            </td>
                            <td><%= showId %></td>
                            <td class="col-name"><%= s.getNameImg() %></td>
                            <td><%= createDateStr %></td>
                            <td class="col-path"><code><%= s.getPath() %></code></td>
                            <td class="col-type"><%= s.getType() %></td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="pagination-wrap" aria-label="Pagination">
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <%
                            int display = 7;
                            int startPage = Math.max(1, pageNum - display/2);
                            int endPage = Math.min(totalPages, startPage + display - 1);
                            startPage = Math.max(1, endPage - display + 1);

                            // prev
                            if (pageNum > 1) {
                        %>
                        <li class="page-item">
                            <a class="page-link page-nav" href="#" data-page="<%= (pageNum-1) %>">&laquo;</a>
                        </li>
                        <% } else { %>
                        <li class="page-item disabled"><span class="page-link">&laquo;</span></li>
                        <% } %>

                        <% for (int p = startPage; p <= endPage; p++) { %>
                        <% if (p == pageNum) { %>
                        <li class="page-item active" aria-current="page"><span class="page-link"><%= p %></span></li>
                        <% } else { %>
                        <li class="page-item"><a class="page-link page-nav" href="#" data-page="<%= p %>"><%= p %></a></li>
                        <% } %>
                        <% } %>

                        <% if (pageNum < totalPages) { %>
                        <li class="page-item"><a class="page-link page-nav" href="#" data-page="<%= (pageNum+1) %>">&raquo;</a></li>
                        <% } else { %>
                        <li class="page-item disabled"><span class="page-link">&raquo;</span></li>
                        <% } %>
                    </ul>
                </nav>
            </div>

            <div id="selectedHiddenContainer"></div>

        </form>

        <div class="bottom-row">
            <div class="bottom-left">
                <button id="btnBack" class="btn btn-outline-secondary btn-sm" title="Back to previous page">
                    <i class="bi bi-arrow-left me-1"></i> Back
                </button>
            </div>

            <div class="bottom-right">
                <div class="small-muted">Selected <span id="selectedCount" class="badge-selected">0</span> / <span id="totalCount"><%= sessionTotal %></span></div>
                <button id="btnRetrain" class="btn btn-primary btn-sm" disabled><i class="bi bi-arrow-repeat me-1"></i> Retrain</button>
            </div>
        </div>

    </div>
</main>

<div class="modal fade" id="retrainModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="retrainModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" role="dialog" aria-live="polite" aria-atomic="true">
            <div class="modal-body text-center" style="padding:22px 20px 10px;">
                <div class="spinner-border text-primary" role="status" aria-hidden="true" style="width:48px;height:48px;"></div>
                <h5 class="mt-3 mb-1" style="font-weight:800;">Retraining model...</h5>
                <p class="small-muted mb-3">Please wait while the model is being retrained.</p>
                <div class="d-flex justify-content-center gap-2 mb-1">
                    <button id="modalCancelBtn" class="btn btn-outline-secondary btn-sm">Cancel</button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="toast-container-top" id="toastContainer" aria-live="polite" aria-atomic="true"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // từ sessionSelected sinh ra một json array string chứa các sample id đã chọn
    <%
       StringBuilder sbInit = new StringBuilder();
       sbInit.append("[");
       boolean firstItem = true;
       for (String sid : sessionSelectedSet) {
         if (sid == null) continue;
         if (!firstItem) sbInit.append(",");
         sbInit.append("\"").append(sid.replace("\\","\\\\").replace("\"","\\\"")).append("\"");
         firstItem = false;
       }
       sbInit.append("]");
    %>
    const initialSelected = <%= sbInit.toString() %>;

    const selectedSet = new Set(initialSelected);
     const sampleTbody = document.getElementById('sampleTbody');
     const selectAllCheckbox = document.getElementById('selectAll');
     const btnClearTop = document.getElementById('btnClearTop');
     const btnRetrain = document.getElementById('btnRetrain');
     const selectedCountEl = document.getElementById('selectedCount');
     const totalCountEl = document.getElementById('totalCount');
     const searchForm = document.getElementById('searchForm');
     const pageInput = document.getElementById('pageInput');
     const selectedHiddenContainer = document.getElementById('selectedHiddenContainer');
     const selectionModeInput = document.getElementById('selectionMode');
     const contextPath = '<%= request.getContextPath() %>';
     const modelIdJS = '<%= modelIdStr %>';
     // cờ tạm: true chỉ trong lần submit ngay khi người dùng click Select All
     let justSelectedAll = false;

    // khi user nhấn search hoặc enter trong ô tìm kiếm, ta sẽ gọi saveSelectionSnapshot() rồi redirect bằng GET
    const btnSearchEl = document.getElementById('btnSearch');
    const searchInputEl = document.getElementById('searchInput');
    function doSearchRedirect() {
        const name = (searchInputEl && searchInputEl.value) ? searchInputEl.value : '';
        // lưu snapshot selection trước khi chuyển
        saveSelectionSnapshot().then(() => {
            const qs = new URLSearchParams();
            if (modelIdJS) qs.set('id', modelIdJS);
            if (name) qs.set('nameImg', name);
            qs.set('page', '1');
            qs.set('pageSize', (document.getElementById('pageSizeInput') && document.getElementById('pageSizeInput').value) || '5');
            window.location.href = contextPath + '/retrain?' + qs.toString();
        }).catch(() => {
            const qs = new URLSearchParams();
            if (modelIdJS) qs.set('id', modelIdJS);
            if (name) qs.set('nameImg', name);
            qs.set('page', '1');
            qs.set('pageSize', (document.getElementById('pageSizeInput') && document.getElementById('pageSizeInput').value) || '5');
            window.location.href = contextPath + '/retrain?' + qs.toString();
        });
    }
    if (btnSearchEl) btnSearchEl.addEventListener('click', function(e){ e.preventDefault(); doSearchRedirect(); });
    if (searchInputEl) searchInputEl.addEventListener('keydown', function(e){ if (e.key === 'Enter') { e.preventDefault(); doSearchRedirect(); } });

    // cập nhật số lượng mẫu đã chọn và tắt nút retrain nếu mẫu = 0
    function updateSelectedCount() {
        selectedCountEl.textContent = selectedSet.size;
        btnRetrain.disabled = (selectedSet.size === 0);
    }

    function updateSelectionMode() {
        const totalCount = parseInt((totalCountEl && totalCountEl.textContent) || '0', 10) || 0;
        if (totalCount > 0 && selectedSet.size === totalCount) selectionModeInput.value = 'all';
        else if (selectedSet.size === 0) selectionModeInput.value = 'none';
        else selectionModeInput.value = 'partial';
    }

    //thiết lập trạng thái selectall dựa trên các check box hiển thị
    function updateSelectAllState() {
        const visibleChecks = Array.from(document.querySelectorAll('input.row-check'));
        if (visibleChecks.length === 0) {
            selectAllCheckbox.checked = false; selectAllCheckbox.indeterminate = false; return;
        }
        const checkedVisible = visibleChecks.filter(cb => cb.checked).length;
        if (checkedVisible === 0) { selectAllCheckbox.checked = false; selectAllCheckbox.indeterminate = false; }
        else if (checkedVisible === visibleChecks.length) { selectAllCheckbox.checked = true; selectAllCheckbox.indeterminate = false; }
        else { selectAllCheckbox.checked = false; selectAllCheckbox.indeterminate = true; }
    }

    // gắn sự kiện change cho từ checbox và cập nhật ui
    function attachRowHandlers() {
        document.querySelectorAll('input.row-check').forEach(cb => {
            cb.addEventListener('change', function () {
                const id = this.value;
                if (this.checked) selectedSet.add(id);
                else selectedSet.delete(id);
                updateSelectAllState();
                updateSelectedCount();
                updateSelectionMode();
            });
        });
    }

    //đồng bộ trạng thái các checkbox trên ui dựa vao selectedSet
    function syncVisibleChecksFromSelectedSet() {
        document.querySelectorAll('input.row-check').forEach(cb => {
            cb.checked = selectedSet.has(cb.value);
        });
        updateSelectAllState();
        updateSelectedCount();
    }

    //trước khi gửi search thì inject input hidden vào form
    function persistSelectedAndVisibleToForm() {
        selectedHiddenContainer.innerHTML = '';
        if (justSelectedAll) {
            const allInp = document.createElement('input');
            allInp.type = 'hidden'; allInp.name = 'allSelected'; allInp.value = '1';
            selectedHiddenContainer.appendChild(allInp);
            // reset cờ để lần submit tiếp theo không gửi lại allSelected
            justSelectedAll = false;
        } else {
            // gửi chỉ các id trên trang hiện tại và các id trong visible đang được check.
            // việc này cho phép server biết những visible nào bị unchecked để remove khỏi session,
            const visible = Array.from(document.querySelectorAll('input.row-check')).map(cb => cb.value);
            visible.forEach(id => {
                const v = document.createElement('input'); v.type='hidden'; v.name='visibleIds'; v.value = id; selectedHiddenContainer.appendChild(v);
            });
            const checkedVisible = Array.from(document.querySelectorAll('input.row-check')).filter(cb => cb.checked).map(cb => cb.value);
            checkedVisible.forEach(id => {
                const si = document.createElement('input'); si.type='hidden'; si.name='selectedIds'; si.value = id; selectedHiddenContainer.appendChild(si);
            });
         }
         // luôn gửi selectionMode flag để UI/logic server có thể render hoặc debug; server sẽ không dùng selectionMode để overwrite
         const mode = (selectionModeInput && selectionModeInput.value) ? selectionModeInput.value : '';
         const modeInp = document.createElement('input'); modeInp.type='hidden'; modeInp.name='selectionMode'; modeInp.value = mode; selectedHiddenContainer.appendChild(modeInp);
     }

    // gửi snapshot selection lên server trước khi search hoặc pagination.
    function saveSelectionSnapshot() {
        // nếu không có selection trên trang hiện tại, vẫn resolve ngay
        // gửi các id đang được tick trên trang hiện tại
        const checkedVisible = Array.from(document.querySelectorAll('input.row-check')).filter(cb => cb.checked).map(cb => cb.value);
        if (!checkedVisible || checkedVisible.length === 0) return Promise.resolve({status:'ok'});
        const params = new URLSearchParams();
        params.append('saveSelection', '1');
        checkedVisible.forEach(id => params.append('selectedIds', id));
        // gửi visibleIds để server có context nếu cần
        const visibleIds = Array.from(document.querySelectorAll('input.row-check')).map(cb => cb.value);
        visibleIds.forEach(id => params.append('visibleIds', id));
        // gửi selectionMode để server có thể biết client hiện đang ở chế độ all/partial/none
        params.append('selectionMode', (selectionModeInput && selectionModeInput.value) ? selectionModeInput.value : '');
         return fetch('<%= request.getContextPath() + "/retrain?saveSelection=1" %>', {
             method: 'POST',
             credentials: 'same-origin',
             headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
             body: params.toString()
         }).then(r => {
             if (!r.ok) throw new Error('saveSelection failed');
             return r.json();
         });
     }

    document.addEventListener('click', function(e) {
        const a = e.target.closest && e.target.closest('.page-nav');
        if (!a) return;
        e.preventDefault();
        const p = a.dataset.page;
        if (!p) return;
        // lưu snapshot selection trước
        saveSelectionSnapshot().then(() => {
            persistSelectedAndVisibleToForm();
            pageInput.value = p;
            searchForm.submit();
        }).catch(err => {
            persistSelectedAndVisibleToForm();
            pageInput.value = p;
            searchForm.submit();
        });
    });

    // khi tick select all tick/untick tất cả các cb visible và update selectedset
    selectAllCheckbox.addEventListener('change', function () {
        if (this.checked) {
            // đánh dấu cờ justSelectedAll, thêm selectAll flag và submit. Server sẽ set sessionSelected = all ids of current filtered.
            selectedHiddenContainer.innerHTML = '';
            const selFlag = document.createElement('input'); selFlag.type = 'hidden'; selFlag.name = 'selectAll'; selFlag.value = '1'; selectedHiddenContainer.appendChild(selFlag);
            // set cờ tạm để gửi allSelected 1 lần
            justSelectedAll = true;
            if (selectionModeInput) selectionModeInput.value = 'all';
            // submit form để server cập nhật selectedSampleIds
            persistSelectedAndVisibleToForm();
            searchForm.submit();
        } else {
            // Khi uncheck: hành xử giống Clear selection
            selectedSet.clear();
            document.querySelectorAll('input.row-check').forEach(cb => cb.checked = false);
            updateSelectAllState();
            updateSelectedCount();

            persistSelectedAndVisibleToForm();
            const clearInput = document.createElement('input');
            clearInput.type = 'hidden'; clearInput.name = 'clearSelection'; clearInput.value = '1';
            selectedHiddenContainer.appendChild(clearInput);
            if (selectionModeInput) selectionModeInput.value = 'none';
            searchForm.submit();
        }
    });

    // xóa toàn bộ các mẫu được chọn và submit form để server refresh
    btnClearTop.addEventListener('click', function (e) {
        e.preventDefault();
        selectedSet.clear();
        document.querySelectorAll('input.row-check').forEach(cb => cb.checked = false);
        updateSelectAllState();
        updateSelectedCount();

        persistSelectedAndVisibleToForm();
        const clearInput = document.createElement('input');
        clearInput.type = 'hidden'; clearInput.name = 'clearSelection'; clearInput.value = '1';
        selectedHiddenContainer.appendChild(clearInput);
        searchForm.submit();
    });

    const retrainModalEl = document.getElementById('retrainModal');
    // tạo model k đóng khi click ra ngoài và k đóng khi click esc
    const retrainModal = new bootstrap.Modal(retrainModalEl, {backdrop:'static', keyboard:false});
    const modalCancelBtn = document.getElementById('modalCancelBtn');

    // gửi thông tin sang cho retrain
    btnRetrain.addEventListener('click', function(e) {
        e.preventDefault();
        if (selectedSet.size === 0) return;

        persistSelectedAndVisibleToForm();

        const params = new URLSearchParams();
        params.append('id', '<%= modelIdStr %>');
        params.append('page', pageInput.value);
        params.append('pageSize', document.getElementById('pageSizeInput').value);
        params.append('nameImg', (document.getElementById('searchInput') && document.getElementById('searchInput').value) || '');
        selectedSet.forEach(id => params.append('selectedIds', id));

        retrainModal.show();
        const bodyText = retrainModalEl.querySelector('.modal-body p.small-muted');
        bodyText.textContent = 'Sending retrain request...';

        fetch('<%= request.getContextPath() + "/retrain" %>', {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params.toString()
        }).then(resp => {
            if (!resp.ok) throw new Error('Network response not ok: ' + resp.status);
            return resp.json();
        }).then(json => {
            console.log('retrain queued:', json);
            // job là mã định danh do server trả về khi yêu cầu tác vụ
            const jobId = json.job_id;
            bodyText.textContent = 'Retrain job queued (id: ' + jobId + '). Waiting for completion...';
            // poll: hành động lặp lại gửi request tới server hỏi trạng thái job xem nó hoàn tất hay thất bại
            const pollInterval = 3000;
            const poller = setInterval(() => {
                fetch('<%= request.getContextPath() + "/retrain?checkStatus=1&jobId=" %>' + encodeURIComponent(jobId), {
                    credentials: 'same-origin'
                })
                    .then(r => r.ok ? r.json() : Promise.reject('status fetch failed'))
                    .then(st => {
                        console.log('status', st);
                        bodyText.textContent = 'Job ' + st.job_id + ' — ' + st.status + (st.message ? ': ' + st.message : '');
                        if (st.status === 'finished') {
                            clearInterval(poller);
                            setTimeout(() => retrainModal.hide(), 600);

                            const form = document.createElement('form');
                            form.method = 'POST';
                            form.action = '<%= request.getContextPath() %>/retrain';
                            form.style.display = 'none';

                            const fJob = document.createElement('input');
                            fJob.type = 'hidden'; fJob.name = 'jobId'; fJob.value = jobId; form.appendChild(fJob);

                            const fRender = document.createElement('input');
                            fRender.type = 'hidden'; fRender.name = 'render'; fRender.value = '1'; form.appendChild(fRender);

                            document.body.appendChild(form);
                            form.submit();
                        }
                        else if (st.status === 'failed' || st.status === 'unknown') {
                            clearInterval(poller);
                            setTimeout(() => retrainModal.hide(), 600);
                            showToast('Retrain ' + st.status + (st.message ? ': ' + st.message : ''));
                        }

                    }).catch(err => {
                    console.error('poll error', err);
                });
            }, pollInterval);
        }).catch(err => {
            console.error('retrain request failed', err);
            retrainModal.hide();
            showToast('Retrain request failed: ' + err.message);
        });
    });
    // tắt retrain model
    modalCancelBtn.addEventListener('click', function(e) {
        e.preventDefault();
        retrainModal.hide();
    });

    //nút back
    document.getElementById('btnBack').addEventListener('click', function(e){
        e.preventDefault();
        if (window.history && window.history.length > 1) window.history.back();
        else window.location.href = '<%= request.getContextPath() %>/home.jsp';
    });
    // hiển thị toast (Bootstrap) với message để thông báo lỗi
    function showToast(msg) {
        try {
            const container = document.getElementById('toastContainer');
            const toast = document.createElement('div');
            toast.className = 'toast align-items-center text-bg-primary border-0';
            toast.setAttribute('role','alert');
            toast.setAttribute('aria-live','assertive');
            toast.setAttribute('aria-atomic','true');
            toast.innerHTML = '<div class="d-flex"><div class="toast-body">'+msg+'</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button></div>';
            container.appendChild(toast);
            const bsToast = new bootstrap.Toast(toast, { delay: 4000 });
            bsToast.show();
            toast.addEventListener('hidden.bs.toast', () => toast.remove());
        } catch (e) {
            alert(msg);
        }
    }

    //khởi tạo lần đầu
    attachRowHandlers();
    syncVisibleChecksFromSelectedSet();
    updateSelectedCount();
    updateSelectionMode();

</script>
</body>
</html>
