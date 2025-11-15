package Entity;

import java.sql.Date;

public class Model {
    private int id;
    private String name;
    private Date updateDate;
    private String path, type;
    private double accuracy, recall, precision, f1;

    public Model() {
    }

    public Model(int id,String name, Date updateDate, String path, double accuracy, double recall, double precision, double f1, String type) {
        this.id = id;
        this.name = name;
        this.updateDate = updateDate;
        this.path = path;
        this.accuracy = accuracy;
        this.recall = recall;
        this.precision = precision;
        this.f1 = f1;
        this.type = type;
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

    public Date getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(Date updateDate) {
        this.updateDate = updateDate;
    }

    public double getAccuracy() {
        return accuracy;
    }

    public void setAccuracy(double accuracy) {
        this.accuracy = accuracy;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public double getRecall() {
        return recall;
    }

    public void setRecall(double recall) {
        this.recall = recall;
    }

    public double getPrecision() {
        return precision;
    }

    public void setPrecision(double precision) {
        this.precision = precision;
    }

    public double getF1() {
        return f1;
    }

    public void setF1(double f1) {
        this.f1 = f1;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public String toString() {
        return "Model{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", updateDate=" + updateDate +
                ", path='" + path + '\'' +
                ", type='" + type + '\'' +
                ", accuracy=" + accuracy +
                ", recall=" + recall +
                ", precision=" + precision +
                ", f1=" + f1 +
                '}';
    }
}
