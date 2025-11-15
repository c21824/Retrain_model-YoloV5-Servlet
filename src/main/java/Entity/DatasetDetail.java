package Entity;

public class DatasetDetail {
    private int id, tblSampleId, tblDatasetId;

    public DatasetDetail() {
    }

    public DatasetDetail(int tblSampleId, int tblDatasetId) {
        this.tblSampleId = tblSampleId;
        this.tblDatasetId = tblDatasetId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getTblSampleId() {
        return tblSampleId;
    }

    public void setTblSampleId(int tblSampleId) {
        this.tblSampleId = tblSampleId;
    }

    public int getTblDatasetId() {
        return tblDatasetId;
    }

    public void setTblDatasetId(int tblDatasetId) {
        this.tblDatasetId = tblDatasetId;
    }
}
