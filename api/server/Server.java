import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.sql.SQLException;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

/*
 * JSON files for each zone(3) holding past 24 hour data
 * 1 JSON file for all zones and data every minute
 * Scheduler in gitlab
 * 
 * 
 */

public class Server implements IServer{

    final int NUMBER_OF_ZONES = 3;
    private boolean hoursUpdated = false;
    private boolean minutesUpdated = false;

    @Override
    public boolean isHoursUpdated() {
        return hoursUpdated;
    }

    @Override
    public boolean isMinutesUpdated() {
        return minutesUpdated;
    }

    @Override
    public void setHoursUpdated(boolean value) {
        this.hoursUpdated = value;
    }

    @Override
    public void setMinutesUpdated(boolean value) {
        this.minutesUpdated = value;
    }

    @Override
    public void insertData(SensorData data, String table) throws RemoteException {
        Populator p = new Populator(table);
        try {
            p.insertSensorData(data.getZone(), data.getDataType(), data.getValue());
        } catch (SQLException e) {
            System.out.println("Error - SensorData could not be imported into database: ");
            e.printStackTrace();
            return;
        }
    }

    @Override
    public SensorData[] getSensorData(int zone, String table) throws RemoteException {
        Populator p = new Populator(table);
        SensorData[] data = null;
        try {
            data = p.requestSensorData(zone);
        } catch (SQLException e) {
            System.out.print("Error getting Sensor Data: ");
            e.printStackTrace();
        }

        return data;
    }

    @Override
    public SensorData[] getAllData(String table) throws RemoteException {
        Populator p = new Populator(table);
        SensorData[] data = null;
        try {
            data = p.getAllData();
        } catch (SQLException e) {
            System.out.print("Error getting Sensor Data: ");
            e.printStackTrace();
        }

        return data;
    }


    @Override
    public SensorData[] getSensorData(String type, String table) throws RemoteException {
        Populator p = new Populator(table);
        SensorData[] data = null;
        try {
            data = p.resuestSensorData(type);
        } catch (SQLException e) {
            System.out.print("Error getting Sensor Data: ");
            e.printStackTrace();
        }

        return data;
    }


    @Override
    public SensorData[] getSensorData(String type, int zone, String table) throws RemoteException {
        Populator p = new Populator(table);
        SensorData[] data = null;
        try {
            data = p.resuestSensorData(type, zone);
        } catch (SQLException e) {
            System.out.print("Error getting Sensor Data: ");
            e.printStackTrace();
        }

        return data;
    }

    public static void main(String[] args) {
        /*Sets up server and RMI Registry */
        try {
            Server s = new Server();
            String name = "server";
            IServer stub = (IServer) UnicastRemoteObject.exportObject(s, 0);
            Registry registry = LocateRegistry.getRegistry();
            registry.rebind(name, stub);
            System.out.println("Server ready");
        
        } catch (Exception e) {
            System.out.println("Error setting up server:");
            e.printStackTrace();
        }

        
        
    }

    @Override
    public void deleteAllFromTable(String table) throws RemoteException {
        Populator p = new Populator(table);
        try {
            p.deleteAll();
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
    }
}