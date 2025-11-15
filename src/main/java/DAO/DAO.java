package DAO;

import java.sql.Connection;
import java.sql.DriverManager;

public class DAO {
    public static Connection con;
    public DAO(){
        if(con == null){
            String URL = "jdbc:mysql://localhost:3306/cccd";
            String USER = "root";
            String PASSWORD = "123456";
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(URL, USER, PASSWORD);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
