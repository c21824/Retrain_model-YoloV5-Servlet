package Servlet;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import DAO.Impl.ModelDAOImpl;
import DAO.ModelDAO;
import Entity.Model;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;

@WebServlet(name = "UpdateModelServlet", value = "/updateModel")
public class UpdateModelServlet extends HttpServlet {
    private final ModelDAO modelDAO = new ModelDAOImpl();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        //đọc json body giúp dễ truy cập các trường hơn
        JsonNode body;
        try {
            body = mapper.readTree(request.getReader());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":false,\"message\":\"Invalid JSON body\"}");
            }
            return;
        }

        HttpSession session = request.getSession(false);
        Model model = (Model) session.getAttribute("model");

        // nhận trường từ json
        String weights = body.get("weights").asText("");

        double accuracy = body.get("accuracy").asDouble();
        double precision = body.get("precision").asDouble();
        double recall = body.get("recall").asDouble();
        double f1 = body.get("f1").asDouble();

        Date now = new Date(System.currentTimeMillis());
        Model updated = new Model(model.getId(), model.getName(), now, weights, accuracy, recall, precision, f1, model.getType());

        boolean ok;
        try {
            ok = modelDAO.updateModelInfo(updated);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\":false,\"message\":\"DB error: " + escapeJson(e.getMessage()) + "\"}");
            }
            return;
        }

        // trả về và cập nhật session
        try (PrintWriter out = response.getWriter()) {
            if (ok) {
                if (session == null) session = request.getSession(true);
                session.removeAttribute("model");
                session.removeAttribute("selectedSampleIds");

                String redirectTo = request.getContextPath() + "/RetrainModel.jsp";
                out.print("{\"success\":true,\"message\":\"Model updated\",\"redirect\":\"" + redirectTo + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Update failed (no rows updated)\"}");
            }
        }
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
