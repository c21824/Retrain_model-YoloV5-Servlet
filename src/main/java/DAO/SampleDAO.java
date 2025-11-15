package DAO;

import Entity.Model;
import Entity.Sample;

import java.util.List;

public interface SampleDAO {
    List<Sample> getSampleByType(String type);
    List<Sample> searchSample(String type, String nameImg);
}
