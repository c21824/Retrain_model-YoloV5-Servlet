package DAO;

import Entity.Model;

public interface ModelDAO {
    Model getModelInfo(int id);
    boolean updateModelInfo(Model model);
}
