public class SensorData implements java.io.Serializable {
    private int zone, value;
    private String dataType;
    
    public SensorData(int zone, String dataType, int value) {
        this.zone = zone;
        this.dataType = dataType;
        this.value = value;
    }

    public int getZone() {
        return this.zone;
    }

    public String getDataType() {
        return this.dataType;
    }
    public int getValue() {
        return this.value;
    }
}