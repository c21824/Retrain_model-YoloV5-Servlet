package DAO.Impl;

import DAO.DAO;
import DAO.DatasetDetailDAO;
import Entity.DatasetDetail;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DatasetDetailImpl extends DAO implements DatasetDetailDAO {

    @Override
    public int createDatasetDetail(DatasetDetail datasetDetail) {
        String sql = "insert into tbldatasetdetail (tblSampleid, tblDatasetid) values (?, ?)";
        try(PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)){
            ps.setInt(1, datasetDetail.getTblSampleId());
            ps.setInt(2, datasetDetail.getTblDatasetId());
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new SQLException("Create dataset failed, no rows affected.");
            }
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new SQLException("Create dataset succeeded but no ID obtained.");
                }
            }
        }catch (Exception ex){
            ex.printStackTrace();
        }
        return 0;
    }
}
