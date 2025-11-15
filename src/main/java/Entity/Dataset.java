package Entity;

public class Dataset {
    private int id;
    private String name;
    private String path;
    private String type;
    private int tblModelId;

    public Dataset(String name, String path, String type, int tblModelId) {
        this.name = name;
        this.path = path;
        this.type = type;
        this.tblModelId = tblModelId;
    }

    public Dataset() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getTblModelId() {
        return tblModelId;
    }

    public void setTblModelId(int tblModelId) {
        this.tblModelId = tblModelId;
    }

    @Override
    public String toString() {
        return "Dataset{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", path='" + path + '\'' +
                ", type='" + type + '\'' +
                ", tblModelId=" + tblModelId +
                '}';
    }
}
