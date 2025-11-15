package DAO.Impl;

import DAO.DAO;
import DAO.SampleDAO;
import Entity.Model;
import Entity.Sample;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class SampleDAOImpl extends DAO implements SampleDAO {

    @Override
    public List<Sample> getSampleByType(String type) {
        String sql = "select * from tblsample where type = ?";
        try(PreparedStatement ps = con.prepareStatement(sql)){
            ps.setString(1,type);
            ResultSet rs = ps.executeQuery();
            List<Sample> list = new ArrayList<>();
            while(rs.next()){
                Sample sample = new Sample();
                sample.setId(rs.getInt("id"));
                sample.setPath(rs.getString("path"));
                sample.setCreateDate(rs.getDate("createDate"));
                sample.setNameImg(rs.getString("nameImg"));
                sample.setType(rs.getString("type"));
                list.add(sample);
            }
            return list;
        }catch(Exception e){
            e.printStackTrace();
        }
        return Collections.emptyList();
    }

    @Override
    public List<Sample> searchSample(String type, String nameImg) {
        nameImg = "%"+nameImg+"%";
        String sql = "select * from tblsample where type = ?  and nameImg like ?";
        try(PreparedStatement ps = con.prepareStatement(sql)){
            ps.setString(1,type);
            ps.setString(2,nameImg);
            ResultSet rs = ps.executeQuery();
            List<Sample> list = new ArrayList<>();
            while(rs.next()){
                Sample sample = new Sample();
                sample.setId(rs.getInt("id"));
                sample.setPath(rs.getString("path"));
                sample.setCreateDate(rs.getDate("createDate"));
                sample.setNameImg(rs.getString("nameImg"));
                sample.setType(rs.getString("type"));
                list.add(sample);
            }
            return list;
        }catch(Exception e){
            e.printStackTrace();
        }
        return Collections.emptyList();
    }


}
