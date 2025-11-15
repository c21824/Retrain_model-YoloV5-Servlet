package Entity;

import java.util.Date;

public class Sample {
    private int id;
    private String nameImg;
    private String path;
    private Date createDate;
    private String type;

    public Sample() {
    }

    public Sample(String nameImg, String path, Date createDate, String type) {
        this.nameImg = nameImg;
        this.path = path;
        this.createDate = createDate;
        this.type = type;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNameImg() {
        return nameImg;
    }

    public void setNameImg(String nameImg) {
        this.nameImg = nameImg;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    @Override
    public String toString() {
        return "Sample{" +
                "id=" + id +
                ", nameImg='" + nameImg + '\'' +
                ", path='" + path + '\'' +
                ", createDate=" + createDate +
                ", type='" + type + '\'' +
                '}';
    }
}
