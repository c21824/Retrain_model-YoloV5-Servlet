package Servlet;

import DAO.Impl.ModelDAOImpl;
import DAO.ModelDAO;
import Entity.Model;
import Utils.Convert;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(value = "/model")
public class ModelServlet extends HttpServlet {
    private ModelDAO modelDAO = new ModelDAOImpl();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        System.out.println(id);
        Model model = modelDAO.getModelInfo(id);

        if(model == null){
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"Model not found\"}");
            return;
        }
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json;charset=UTF-8");
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"name\":").append(jsonEscape(model.getName())).append(",");
        sb.append("\"updateDate\":").append(jsonEscape(Convert.formatDateToString(model.getUpdateDate()))).append(",");
        sb.append("\"accuracy\":").append(jsonEscape(Convert.formatDoubleString(model.getAccuracy()))).append(",");
        sb.append("\"precision\":").append(jsonEscape(Convert.formatDoubleString(model.getPrecision()))).append(",");
        sb.append("\"recall\":").append(jsonEscape(Convert.formatDoubleString(model.getRecall()))).append(",");
        sb.append("\"f1\":").append(jsonEscape(Convert.formatDoubleString(model.getF1())));
        sb.append("}");
        response.getWriter().write(sb.toString());
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    }

    //chuyển string thành dạng an toàn để truyền vào json
    private static String jsonEscape(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n","\\n").replace("\r","\\r") + "\"";
    }
}
