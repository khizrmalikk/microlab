import java.rmi.Remote;
import java.rmi.RemoteException;

public interface IServer extends Remote {
    
    public void insertData(SensorData data, String table) throws RemoteException;
    public SensorData[] getSensorData(int zone, String table) throws RemoteException;
    public SensorData[] getSensorData(String type, String table) throws RemoteException;
    public SensorData[] getSensorData(String type, int zone, String table) throws RemoteException;
    public SensorData[] getAllData(String table) throws RemoteException;
    public void deleteAllFromTable(String table) throws RemoteException;

    public boolean isHoursUpdated() throws RemoteException;
    public boolean isMinutesUpdated() throws RemoteException;
    public void setHoursUpdated(boolean value) throws RemoteException;
    public void setMinutesUpdated(boolean value) throws RemoteException;
}