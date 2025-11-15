package Servlet;

import DAO.AdminDAO;
import DAO.Impl.AdminDAOImpl;
import Entity.Admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;


@WebServlet(value = "/login")
public class LoginServlet extends HttpServlet {
    private AdminDAO adminDAO = new AdminDAOImpl();
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        Admin admin = adminDAO.checkLogin(username, password);
        if(admin.getFullName() != null){
            HttpSession session = req.getSession();
            session.setAttribute("admin", admin);
            resp.sendRedirect(req.getContextPath()+"/Home.jsp");
        }
        else{
            req.setAttribute("error", "Wrong username or password.");
            req.getRequestDispatcher("/Login.jsp").forward(req, resp);
        }
    }

}
