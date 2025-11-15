package DAO;

import Entity.Admin;

import java.sql.SQLException;

public interface AdminDAO {
    Admin checkLogin(String username, String password);
}
