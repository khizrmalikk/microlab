import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

import java.util.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.io.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileOutputStream;
import static java.util.concurrent.TimeUnit.*;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

/**
 * Client
 */
public class WebsiteClient {

    final static int NUMBER_OF_ZONES = 3;
    final static String[] types = {"N", "L", "T"};
    private final static ScheduledExecutorService scheduler =
       Executors.newScheduledThreadPool(1);
    static IServer server;
    

    @SuppressWarnings("unchecked")
    private static JSONArray convertToJson(SensorData[] data) {
        JSONObject singleData;
        JSONArray dataArray = new JSONArray();
        int time = 0;

        for (int i = 0; i < data.length; i++) {
            singleData = new JSONObject();
            singleData.put("zone", data[i].getZone());
            singleData.put("type", data[i].getDataType());
            singleData.put("value", data[i].getValue());
            singleData.put("time", time);
            dataArray.add(singleData);
            time--;
            if (time == -24) {
                return dataArray;
            }
        }
        return dataArray;
    }

    final static Runnable hourSave = new Runnable() {
  
        @Override
        public void run() {
            SensorData[] dataArray;
            JSONArray zoneArray = new JSONArray();

            /* Checks if the json has been updated */
            try {
                while (server.isHoursUpdated() == false) {
                    System.out.println("Waiting for hourly update...");
                    
                    Thread.sleep(1000); //Waits for 1 second
                }
            } catch (Exception e1) {
                e1.printStackTrace();
            }

            /* Loads all data into JSON */
            System.out.println("Attempting to save hours_data.json");
            try {
                for (int i = 1; i < NUMBER_OF_ZONES + 1; i++) {
                    for (int j = 0; j < types.length; j++) {
                        dataArray = server.getSensorData(types[j], i, "hours_data");
                        zoneArray.addAll(convertToJson(dataArray));
                    }
                }
                try {
                    Files.write(Paths.get("../assets/hours_data.json"), zoneArray.toJSONString().getBytes()); //Prints file
                    System.out.println("hours_data.json saved @" + System.currentTimeMillis());
                    server.setHoursUpdated(true);
                } catch (IOException e) {
                    System.out.print("Error writing to file IN hourly update:");
                    e.printStackTrace();
                }
            } catch (RemoteException e) {
                System.out.print("Error in hourly JSON update:");
                e.printStackTrace();
            }
            try {
                server.setHoursUpdated(false);
            } catch (RemoteException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    };

    public static Runnable minSave = new Runnable() {
        @Override
        public void run() {
            SensorData[] dataArray;
            JSONArray jsonArray;

            /* Checks if the json has been updated */
            try {
                while (server.isMinutesUpdated() == false) {
                    System.out.println("Waiting for minute update...");
                    
                    Thread.sleep(1000); //Waits for 1 second
                }
            } catch (Exception e1) {
                e1.printStackTrace();
            }
    
            try {
                System.out.println("Attempting to save minute_data.json");
                dataArray = server.getAllData("minute_data");
                jsonArray = convertToJson(dataArray);
                try {
                    Files.write(Paths.get("../assets/minute_data.json"), jsonArray.toJSONString().getBytes());
                    System.out.println("minute_data.json saved @" + System.currentTimeMillis());
                } catch (IOException e) {
                    System.out.print("Error writing to file IN minute update:");
                    e.printStackTrace();
                }
            } catch (RemoteException e) {
                System.out.print("Error in minute JSON update:");
                e.printStackTrace();
            }
            try {
                server.setMinutesUpdated(false);
            } catch (RemoteException e) {
                System.out.println("Error accessing server in minuteJSON update:");
                e.printStackTrace();
            }
        }
    };
    
    private static void populateWithDummy() {
        /* Hour Data */
        for (int i = 1; i < NUMBER_OF_ZONES + 1; i++) {
            for (int j = 0; j < types.length; j++) {
                for (int k = 0; k < 24; k++) {
                    SensorData data = new SensorData(i, types[j], new Random().nextInt(90));
                    try {
                        server.insertData(data, "hours_data");
                    } catch (RemoteException e) {
                        System.out.println("Failed populating hours_data with dummy data: ");
                        e.printStackTrace();
                    }
                }
            }
        }

        /* Minute Data */
        for (int i = 1; i < NUMBER_OF_ZONES + 1; i++) {
            for (int j = 0; j < types.length; j++) {
                SensorData data = new SensorData(i, types[j], new Random().nextInt(90));
                try {
                    server.insertData(data, "minute_data");
                } catch (RemoteException e) {
                    System.out.println("Failed populating minutes_data with dummy data: ");
                    e.printStackTrace();
                }
            }
        }
    }

    
    public static void main(String[] args) {
        try {
            /*CONNECT TO SERVER */
            String name = "server";
            Registry registry = LocateRegistry.getRegistry("localhost");
            server = (IServer) registry.lookup(name);
            System.out.println("Connected");
            
            /*CLIENT CODE */
           // populateWithDummy();

            // Scheduling for every minute
            final ScheduledFuture<?> beeperHandle = scheduler.scheduleAtFixedRate(minSave, 0, 60, SECONDS); // 10 seconds till start and then 60 seconds between each run
            scheduler.schedule(new Runnable() {
                public void run() { beeperHandle.cancel(false); }
            }, 60*60*24, SECONDS); // 60*60 is how long it will run for

            //Scheduling for getting the data every hour
            final ScheduledFuture<?> beeperHandle2 = scheduler.scheduleAtFixedRate(hourSave, 5, 60*60, SECONDS); // 10 seconds till start and then 1 hour between each run
            scheduler.schedule(new Runnable() {
                    public void run() { beeperHandle2.cancel(false); }
            }, 60*60*24, SECONDS); // 60 * 60 is how long it will run for    
            
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
    
}