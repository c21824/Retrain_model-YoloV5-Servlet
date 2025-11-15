package Entity;

public class Label {
    private int id;
    private double xTop, yTop, xBot, yBoy;
    private String label;
    private int tblSampleId;

    public Label() {
    }

    public Label(double xTop, double yTop, double xBot, double yBoy, String label, int tblSampleId) {
        this.xTop = xTop;
        this.yTop = yTop;
        this.xBot = xBot;
        this.yBoy = yBoy;
        this.label = label;
        this.tblSampleId = tblSampleId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public double getxTop() {
        return xTop;
    }

    public void setxTop(double xTop) {
        this.xTop = xTop;
    }

    public double getyTop() {
        return yTop;
    }

    public void setyTop(double yTop) {
        this.yTop = yTop;
    }

    public double getxBot() {
        return xBot;
    }

    public void setxBot(double xBot) {
        this.xBot = xBot;
    }

    public double getyBoy() {
        return yBoy;
    }

    public void setyBoy(double yBoy) {
        this.yBoy = yBoy;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public int getTblSampleId() {
        return tblSampleId;
    }

    public void setTblSampleId(int tblSampleId) {
        this.tblSampleId = tblSampleId;
    }
}
