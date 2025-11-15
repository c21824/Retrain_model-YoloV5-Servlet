package DAO.Impl;

import DAO.DAO;
import DAO.DatasetDAO;
import Entity.Dataset;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DatasetDAOImpl extends DAO implements DatasetDAO {

    @Override
    public int datasetCount() {
        String sql = "select count(*) from tbldataset";
        try(PreparedStatement ps = con.prepareStatement(sql)){
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int createDataset(Dataset dataset) {
        String sql = "insert into tbldataset (name, path, type, tblModelid) values (?, ?, ?, ?)";
        try(PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)){
            ps.setString(1, dataset.getName());
            ps.setString(2, dataset.getPath());
            ps.setString(3, dataset.getType());
            ps.setInt(4, dataset.getTblModelId());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new SQLException("Create dataset failed, no rows affected.");
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // trả về id vừa tạo
                } else {
                    throw new SQLException("Create dataset succeeded but no ID obtained.");
                }
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        return 0;
    }
}
