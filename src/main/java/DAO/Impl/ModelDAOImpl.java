package DAO.Impl;

import DAO.DAO;
import DAO.ModelDAO;
import Entity.Model;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class ModelDAOImpl extends DAO implements ModelDAO {

    @Override
    public Model getModelInfo(int id) {
        String sql = "select * from tblmodel where id = ?";
        try(PreparedStatement ps = con.prepareStatement(sql)){
            ps.setInt(1,id);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                Model m = new Model();
                m.setId(rs.getInt("id"));
                m.setName(rs.getString("name"));
                m.setPath(rs.getString("path"));
                m.setUpdateDate(rs.getDate("updateDate"));
                m.setType(rs.getString("type"));
                m.setAccuracy(rs.getDouble("accuracy"));
                m.setF1(rs.getDouble("f1"));
                m.setPrecision(rs.getDouble("precision"));
                m.setRecall(rs.getDouble("recall"));
                return m;
            }

        }catch(Exception e){
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean updateModelInfo(Model model) {
        String sql = "UPDATE tblmodel SET "
                + "`precision` = ?, `recall` = ?, `f1` = ?, `accuracy` = ?, "
                + "`path` = ?, `updateDate` = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, model.getPrecision());
            ps.setDouble(2, model.getRecall());
            ps.setDouble(3, model.getF1());
            ps.setDouble(4, model.getAccuracy());
            ps.setString(5, model.getPath());

            java.sql.Date sqlDate = null;
            if (model.getUpdateDate() != null) {
                if (model.getUpdateDate() instanceof java.sql.Date) {
                    sqlDate = (java.sql.Date) model.getUpdateDate();
                } else {
                    sqlDate = new java.sql.Date(model.getUpdateDate().getTime());
                }
                ps.setDate(6, sqlDate);
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }
            ps.setInt(7, model.getId());
            int updated = ps.executeUpdate();
            return updated > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}
