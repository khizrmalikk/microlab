import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

import java.util.Scanner;

import com.fazecast.jSerialComm.SerialPort;
import com.fazecast.jSerialComm.SerialPortDataListener;
import com.fazecast.jSerialComm.SerialPortEvent;


public class RelayClient {
    private static IServer server;
    SensorData[] minData;
    String serialData = new String();
    int zonesRecieved;
    int minutesPassed;



    private void sendToDB(String reading) {
        try {
            String[] buffer = reading.split("\n");
            for (int i = 0; i < buffer.length; i++) {
                if (buffer[i].length() >= 6) {
                    System.out.println(buffer[i]);
                    String[] temp = buffer[i].split("-");
                    SensorData data = new SensorData(Integer.parseInt(temp[0]), temp[1],
                            Integer.parseInt(temp[2].trim()));
                    if (data.getDataType() != "P") {
                        try { 
                            server.insertData(data, "minute_data");
                            System.out.println("Data: " + data.getZone() + data.getDataType() + data.getValue());
                            System.out.println("Minute data inserted @" + System.currentTimeMillis());
                            server.setMinutesUpdated(true);

                            minData[zonesRecieved] = data;
                            System.out.println(zonesRecieved);;
                            zonesRecieved++;
                            if (zonesRecieved == 9) {
                                minutesPassed++;
                                zonesRecieved = 0;
                            }
                            if (minutesPassed == 60) {
                                minutesPassed = 0;
                                try {
                                    for (int ii = 0; ii < 9; ii++) {
                                        server.insertData(minData[ii], "hour_data");
                                        System.out.println("Hour data inserted @" + System.currentTimeMillis());
                                        server.deleteAllFromTable("minute_data");
                                    }
                                    server.setHoursUpdated(true);
                                } catch (RemoteException e) {
                                    System.out.println("Error inserting to hour_data...");
                                    e.printStackTrace();
                                }
                            }
                        } catch (RemoteException e) {
                            System.out.println("Error inserting to minute_data...");
                            e.printStackTrace();
                        }
                    } else {
                        try {
                            server.insertData(data, "location_history");
                            System.out.println("Location data inserted @" + System.currentTimeMillis());
                        } catch (RemoteException e) {
                            System.out.println("Error inserting to location_history...");
                            e.printStackTrace();
                        }
                    }
                }
            }

            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
        

    //public static Runnable hourSave = new Runnable() {
    //    @Override
    //    public void run() {
    //        try {
    //            //server.insertData(data, "hour_data");
    //            System.out.println("Hour data inserted @" + System.currentTimeMillis());
    //            server.setHoursUpdated(true);
    //        } catch (RemoteException e) {
    //            System.out.println("Error inserting to hour_data...");
    //            e.printStackTrace();
    //        }
    //    }
    //};

    public void showAllPort() {
        int i = 0;
        for (SerialPort port : ports) {
            System.out.print(i + ". " + port.getDescriptivePortName() + " ");
            System.out.println(port.getPortDescription());
            i++;
        }
    }
        
    SerialPort activePort;
    SerialPort[] ports = SerialPort.getCommPorts();

    public void setPort(int portIndex, RelayClient client) {
        activePort = ports[portIndex];

        if (activePort.openPort()) {
            System.out.println(activePort.getPortDescription() + " port opened.");
        }
        activePort.setComPortParameters(115200, Byte.SIZE, SerialPort.ONE_STOP_BIT, SerialPort.NO_PARITY);
        activePort.addDataListener(new SerialPortDataListener() {
          @Override
          public void serialEvent(SerialPortEvent event) {
                int size = event.getSerialPort().bytesAvailable();
                byte[] buffer = new byte[size];
                event.getSerialPort().readBytes(buffer, size);     
                for (byte b : buffer) {
                    if (((char) b) == '#') {
                        sendToDB(serialData);
                        serialData = "";
                    } else {
                        serialData += ((char) b);
                    }
                }
            }
            
          @Override
          public int getListeningEvents() {
              return SerialPort.LISTENING_EVENT_DATA_AVAILABLE;
          }
        });
    }
    public void start(RelayClient client) {
		showAllPort();
		Scanner reader = new Scanner(System.in);
		System.out.print("Port? ");
        int p = reader.nextInt();
        
		setPort(p, client);
		reader.close();
	}


    public static void main(String[] args) {
        /*CONNECT TO SERVER */
        try{
            String name = "server";
            Registry registry = LocateRegistry.getRegistry("localhost");
            server = (IServer) registry.lookup(name);
            System.out.println("Connected");
        } catch (Exception e) {
            System.out.println("Error connecting to server:");
            e.printStackTrace();
        }

        /*MONITERING THE SERIAL PORT */
        try {
            RelayClient client = new RelayClient();
            client.minutesPassed = 59;
            client.zonesRecieved = 0;
            client.minData = new SensorData[9];
            client.start(client);

        } catch (Exception e) {
            System.out.println("Error monitering port...");
            e.printStackTrace();
        }
    }   
            
}
