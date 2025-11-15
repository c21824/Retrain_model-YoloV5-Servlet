package Servlet;

import DAO.DatasetDAO;
import DAO.DatasetDetailDAO;
import DAO.Impl.DatasetDAOImpl;
import DAO.Impl.DatasetDetailImpl;
import DAO.Impl.ModelDAOImpl;
import DAO.Impl.SampleDAOImpl;
import DAO.ModelDAO;
import DAO.SampleDAO;
import Entity.Dataset;
import Entity.DatasetDetail;
import Entity.Model;
import Entity.Sample;
import Utils.Convert;
import Utils.TranningService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.stream.Collectors;

@WebServlet(value = "/retrain")
public class RetrainServlet extends HttpServlet {
    private ModelDAO modelDAO = new ModelDAOImpl();
    private SampleDAO sampleDAO = new SampleDAOImpl();
    private DatasetDAO datasetDAO = new DatasetDAOImpl();
    private DatasetDetailDAO datasetDetailDAO = new DatasetDetailImpl();

//    khởi tạo các map để lưu lại trangj thái job
    private static final ConcurrentMap<String, String> jobStatusMap = new ConcurrentHashMap<>();
    private static final ConcurrentMap<String, String> jobMessageMap = new ConcurrentHashMap<>();
    private static final ConcurrentMap<String, String> jobExternalIdMap = new ConcurrentHashMap<>();
    private static final ConcurrentMap<String, Map<String, Object>> jobResultMap = new ConcurrentHashMap<>();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        // xử lý saveSelection request: client gửi snapshot các selectedIds để server lưu
        if ("1".equals(req.getParameter("saveSelection"))) {
            HttpSession session0 = req.getSession(true);
            String[] sel = req.getParameterValues("selectedIds");
            Set<String> set = new HashSet<>();
            if (sel != null) {
                for (String s : sel) if (s != null && !s.trim().isEmpty()) set.add(s.trim());
            }
            // Thay vì ghi đè hoàn toàn selection trong session, hợp nhất các id được gửi

            Set<String> existing = (Set<String>) session0.getAttribute("selectedSampleIds");
            if (existing == null) existing = new HashSet<>();
            existing.addAll(set);
            session0.setAttribute("selectedSampleIds", existing);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"status\":\"ok\"}");
            return;
        }

//nếu đây không phải AJAX và chứa tham số
        String xReq = req.getHeader("X-Requested-With");
        boolean isAjax = xReq != null && "XMLHttpRequest".equalsIgnoreCase(xReq);
        boolean hasSelectionParams = req.getParameter("selectedIds") != null || req.getParameter("visibleIds") != null
                || req.getParameter("allSelected") != null || req.getParameter("selectAll") != null || req.getParameter("clearSelection") != null;
        if (!isAjax && hasSelectionParams) {
            // xử lý giống get
            doGet(req, resp);
            return;
        }

        //nếu render=1 thì gửi thông tin sang trang update
        String render = req.getParameter("render");
        if ("1".equals(render)) {
            String jobId = req.getParameter("jobId");
            if (jobId == null || jobId.trim().isEmpty()) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing jobId for render");
                return;
            }
            Map<String, Object> result = jobResultMap.get(jobId);
            if (result == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Result for job not found (maybe not finished)");
                return;
            }
            req.setAttribute("metrics", result.get("metrics"));
            req.setAttribute("weights", result.get("weights"));
            req.setAttribute("svcResp", result.get("svcResp"));
            req.getRequestDispatcher("/UpdateModelInfo.jsp").forward(req, resp);
            return;
        }

        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(true);
        Model model = (Model) session.getAttribute("model");

        String[] selectedIdsParam = req.getParameterValues("selectedIds");

        List<Integer> sampleIds = new ArrayList<>();
        if (selectedIdsParam != null && selectedIdsParam.length > 0) {
            for (String s : selectedIdsParam) {
                if (s == null) continue;
                s = s.trim();
                if (s.isEmpty()) continue;
                try { sampleIds.add(Integer.parseInt(s)); } catch (NumberFormatException ignored) {}
            }
        } else {
            Set<String> sessionSelected = (Set<String>) session.getAttribute("selectedSampleIds");
            if (sessionSelected != null) {
                for (String sid : sessionSelected) {
                    if (sid == null) continue;
                    try { sampleIds.add(Integer.parseInt(sid.trim())); } catch (NumberFormatException ignored) {}
                }
            }
        }

        System.out.println("Received: " + sampleIds.size() + " selected sample ids.");

        int datasetCount = datasetDAO.datasetCount();
        String datasetName = "dataset" + (datasetCount + 1);
        String datasetPath = "/data/datasets/dataset" + (datasetCount + 1);
        Dataset dataset = new Dataset(datasetName, datasetPath, model.getType(), model.getId());
        System.out.println("Creating dataset: " + dataset);
        int datasetId = datasetDAO.createDataset(dataset);

        List<Integer> createdDetailIds = new ArrayList<>();
        for (Integer sid : sampleIds) {
            DatasetDetail dd = new DatasetDetail(sid, datasetId);
            int createdId = datasetDetailDAO.createDatasetDetail(dd);
            createdDetailIds.add(createdId);
        }
        System.out.println("Created datasetId=" + datasetId + " with " + createdDetailIds.size() + " details.");

        final String jobId = "job-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        jobStatusMap.put(jobId, "queued");
        jobMessageMap.put(jobId, "queued by admin");
        System.out.println("Job queued: " + jobId);

        final int modelIdFinal = model.getId();
        final int datasetIdFinal = datasetId;
//        tạo thread mới
        new Thread(() -> {
            try {
                jobStatusMap.put(jobId, "running");
                jobMessageMap.put(jobId, "calling training service");

                System.out.println("RetrainJob-" + jobId + " calling training service model=" + modelIdFinal + " dataset=" + datasetIdFinal);
                Map<String, Object> svcResp = TranningService.callTrainingService(modelIdFinal, datasetIdFinal, model.getPath());
                System.out.println("RetrainJob-" + jobId + " svcResp=" + svcResp);

                Map<String, Double> metrics = Convert.extractMetrics(svcResp);
                String weights = Convert.getWeightsFromSvcResp(svcResp);
                System.out.println("[RetrainJob-" + jobId + "] metrics=" + metrics + " weights=" + weights);

                if (svcResp != null && svcResp.get("job_id") != null) {
                    String externalJobId = svcResp.get("job_id").toString();
                    jobExternalIdMap.put(jobId, externalJobId);
                    jobMessageMap.put(jobId, "external job: " + externalJobId);
                }

                Map<String, Object> result = new HashMap<>();
                result.put("metrics", metrics);
                result.put("weights", weights);
                result.put("svcResp", svcResp);
                jobResultMap.put(jobId, result);

                jobStatusMap.put(jobId, "finished");
                jobMessageMap.put(jobId, "finished");
                System.out.println("[RetrainJob-" + jobId + "] finished.");

            } catch (Exception ex) {
                jobStatusMap.put(jobId, "failed");
                jobMessageMap.put(jobId, ex.getMessage() != null ? ex.getMessage() : "error calling training service");
                ex.printStackTrace();
                System.err.println("[RetrainJob-" + jobId + "] failed: " + ex.getMessage());
            }
        }, "retrain-job-" + jobId).start();

        String json = String.format("{\"status\":\"queued\",\"job_id\":\"%s\",\"dataset_id\":%d}", jobId, datasetId);
        PrintWriter out = resp.getWriter();
//        ghi chuoi json vao body
        out.write(json);
        out.flush();
    }


    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String check = req.getParameter("checkStatus");
        String jobId = req.getParameter("jobId");
//      trả lại trạng thái job
        if ("1".equals(check) && jobId != null && !jobId.trim().isEmpty()) {
            resp.setContentType("application/json; charset=UTF-8");
            String status = jobStatusMap.getOrDefault(jobId, "unknown");
            String message = jobMessageMap.getOrDefault(jobId, "");
            String external = jobExternalIdMap.getOrDefault(jobId, "");
            message = message.replace("\"", "\\\"");
            String json = String.format("{\"job_id\":\"%s\",\"status\":\"%s\",\"message\":\"%s\",\"external_job_id\":\"%s\"}",
                    jobId, status, message, external);
            resp.getWriter().write(json);
            return;
        }

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(true);

        Model model = null;
        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                model = modelDAO.getModelInfo(id);
                System.out.println(model);
                if (model != null) session.setAttribute("model", model);
            } catch (NumberFormatException ignored) {}
        }

        String nameImg = req.getParameter("nameImg");
        if (nameImg != null) nameImg = nameImg.trim();
        String pageStr = req.getParameter("page");
        String pageSizeStr = req.getParameter("pageSize");

//      lấy trang hiện tại và kích thước trang
        int page = 1;
        int pageSize = 5;
        try { if (pageStr != null) page = Math.max(1, Integer.parseInt(pageStr)); } catch (NumberFormatException ignored) {}
        try { if (pageSizeStr != null) pageSize = Math.max(1, Integer.parseInt(pageSizeStr)); } catch (NumberFormatException ignored) {}

        List<Sample> filtered = new ArrayList<>();
        if (nameImg == null || nameImg.isEmpty()) {
            filtered = sampleDAO.getSampleByType(model.getType());
            session.setAttribute("totalCount", filtered.size());
            if (filtered == null) filtered = new ArrayList<>();
        } else {
            filtered = sampleDAO.searchSample(model.getType(), nameImg);
            if (filtered == null) filtered = new ArrayList<>();
            int currentTotal = filtered.size();
            req.setAttribute("currentTotalCount", currentTotal);
        }

        // lấy các tham số liên quan selection
        String[] selectedIdsParam = req.getParameterValues("selectedIds");
        String[] visibleIdsParam = req.getParameterValues("visibleIds");
        String clearFlag = req.getParameter("clearSelection");
        String selectAllParam = req.getParameter("selectAll");
        String allSelectedParam = req.getParameter("allSelected");

         Set<String> sessionSelected = (Set<String>) session.getAttribute("selectedSampleIds");
         if (sessionSelected == null) {
             sessionSelected = new HashSet<>();
         }

        // clear selection nếu có flag
        if (clearFlag != null && ("1".equals(clearFlag) || "true".equalsIgnoreCase(clearFlag))) {
            sessionSelected.clear();
        }

        // nếu client yêu cầu chọn tất cả
        if ((selectAllParam != null && ("1".equals(selectAllParam) || "true".equalsIgnoreCase(selectAllParam)))
                || (allSelectedParam != null && ("1".equals(allSelectedParam) || "true".equalsIgnoreCase(allSelectedParam)))) {
            Set<String> allIds = new HashSet<>();
            for (Sample s : filtered) {
                if (s != null) allIds.add(String.valueOf(s.getId()));
            }
            sessionSelected.addAll(allIds);
        } else {
            // Thêm các mẫu được chọn vào set
            if (selectedIdsParam != null) {
                for (String sid : selectedIdsParam) {
                    if (sid != null && !sid.trim().isEmpty()) {
                        sessionSelected.add(sid.trim());
                    }
                }
            }

            // Loại bỏ các visibleid nếu không được checked khỏi set
            if (visibleIdsParam != null && selectedIdsParam != null) {
                Set<String> visibleSet = new HashSet<>();
                for (String vid : visibleIdsParam) {
                    if (vid != null && !vid.trim().isEmpty()) visibleSet.add(vid.trim());
                }
                Set<String> currentlyChecked = new HashSet<>();
                for (String sid : selectedIdsParam) if (sid != null && !sid.trim().isEmpty()) currentlyChecked.add(sid.trim());
                for (String vid : visibleSet) {
                    if (!currentlyChecked.contains(vid)) sessionSelected.remove(vid);
                }
            }
        }

        // lưu lại session
        session.setAttribute("selectedSampleIds", sessionSelected);

        // xác định selectionMode để jsp khởi tạo đúng (all/partial/none)
        String selectionMode = "partial";
        if (sessionSelected.isEmpty()) selectionMode = "none";
        else if (filtered.size() > 0 && sessionSelected.size() == filtered.size()) selectionMode = "all";
        req.setAttribute("selectionMode", selectionMode);

        int totalCount = filtered.size();
        int offset = (page - 1) * pageSize;
        int toIndex = Math.min(offset + pageSize, totalCount);
        List<Sample> pageList;
        if (offset >= totalCount || offset < 0) {
            pageList = new ArrayList<>();
        } else {
            pageList = filtered.subList(offset, toIndex);
        }

        req.setAttribute("sampleList", pageList);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("selectedCount", sessionSelected.size());

        req.getRequestDispatcher("/SelectSample.jsp").forward(req, resp);
    }
}
