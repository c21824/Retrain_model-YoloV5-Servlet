package DAO;

import Entity.Dataset;

public interface DatasetDAO {
    int datasetCount();
    int createDataset(Dataset dataset);
}
