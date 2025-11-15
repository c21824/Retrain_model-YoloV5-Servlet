package DAO.Impl;

import DAO.DAO;
import Entity.Admin;
import DAO.AdminDAO;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AdminDAOImpl extends DAO implements AdminDAO {
    public Admin checkLogin(String username, String password) {
        String sql = "select * from tbladmin where username=? and password=?";
        try(PreparedStatement ps = con.prepareStatement(sql)){
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            Admin  admin = new Admin();
            while(rs.next()){
                admin.setId(rs.getInt("id"));
                admin.setUsername(rs.getString("username"));
                admin.setPassword(rs.getString("password"));
                admin.setEmail(rs.getString("email"));
                admin.setFullName(rs.getString("fullName"));
                admin.setPhoneNumber(rs.getString("phoneNumber"));
            }
            return admin;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return null;
    }
}
