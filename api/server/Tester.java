import java.rmi.registry.*;
import java.rmi.server.UnicastRemoteObject;
import java.sql.Connection;
import java.sql.DriverManager;
import org.junit.Assert;
import org.junit.jupiter.api.*;



public class Tester {
    

    public String table = "testTable";


    /**
     * Test to launch server as found in server.java/main - fails if exception is thrown
     * @Note requires java rmiregistry to be available, otherwise java.rmi.registry exception is thrown
     */
    @Test
    void testLaunchServer()
    {
        try {
            Server s = new Server();
            String name = "server";
            IServer stub = (IServer) UnicastRemoteObject.exportObject(s, 0);
            Registry registry = LocateRegistry.getRegistry();
            registry.rebind(name, stub);
        } catch (Exception e) {
            Assert.fail("Exception " + e);
        }
    }


    /**
     *  Test to launch a database connection
     *  @Note requires correct url, currently uses absolute path from personal PC
     */
    @Test
    void testConnectDB()
    {
        Connection sqlite = null;
        
        try {
            Class.forName("org.sqlite.JDBC");
            String url = "D:\\Documents\\Uni\\SCC330\\microbit-Martin\\Databases\\database.db";
            sqlite = DriverManager.getConnection("jdbc:sqlite:" + url);  // NOTE: fix to connect to firebase
        } catch (Exception e) {
            Assert.fail("Exception: " + e);
        }
    }


    @Test
    void testAddData(){
        //TODO create seperate table in DB called "testTable"
            // TODO implement adding data to firebase DB
    }

    @Test
    void testretrieveData()
    {
        // TODO implement read data from firebase DB
    }

    @Test
    void testDeleteData()
    {
        // TODO implement delete data from firebase DB
    }

    @Test
    void testParseData(){
        // TODO implement function to parse input from serial
    }

    @Test
    void testParseDataThrowsException(){
        // TODO implement function to parse invalid data from serial and assert that it throws exception
    }
}

