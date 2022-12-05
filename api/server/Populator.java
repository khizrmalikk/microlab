import java.rmi.RemoteException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Populator {

    private static final boolean debug = false;
    private String table;

    public Populator(String table) {
        this.table = table;
    }

    public void deleteAll() throws SQLException{
        String sqlCommand;
        sqlCommand = "DELETE FROM '" + table + "';";
        System.out.println(sqlCommand);
        this.exec(sqlCommand);
    }

    public void insertSensorData(int zone, String dataType, int value) throws SQLException {
        String sqlCommand;
        sqlCommand = "INSERT OR IGNORE INTO '" + table + "'('Zone','Data Type','Value','Time') VALUES ("; // Start of INSERT statement
        sqlCommand += zone + ",'" + dataType + "'," + value + "," + System.currentTimeMillis() / 1000; // Appends values to the statement
        sqlCommand += ");"; // Closes the statement
        System.out.println(sqlCommand);
        this.exec(sqlCommand);
    }

    public SensorData[] getAllData() throws SQLException {
        String sqlCommand = "SELECT * FROM '" + table + "' ORDER BY 'Time' DESC;";
        System.out.println(sqlCommand);
        ResultSet rs = this.exec(sqlCommand);

        ArrayList<SensorData> data = new ArrayList<>();
        while (rs.next()) {
            int zone = rs.getInt("Zone");
            String type = rs.getString("Data Type");
            int value = rs.getInt("Value");
            data.add(new SensorData(zone, type, value));
        }
        return data.toArray(new SensorData[data.size()]);
    }

    public SensorData[] requestSensorData(int zone) throws SQLException{
        String sqlCommand = "SELECT * FROM '" + table + "' WHERE ";
        sqlCommand += "Zone = " + zone;
        sqlCommand += "ORDER BY 'Time' DESC;";
        System.out.println(sqlCommand);
        ResultSet rs = this.exec(sqlCommand);

        ArrayList<SensorData> data = new ArrayList<>();
        while (rs.next()) {
            String type = rs.getString("Data Type");
            int value = rs.getInt("Value");
            data.add(new SensorData(zone, type, value));
        }
        return data.toArray(new SensorData[data.size()]);
    }

    public SensorData[] resuestSensorData(String type) throws SQLException {
        String sqlCommand = "SELECT * FROM '" + table + "' WHERE ";
        sqlCommand += "\"Data Type\" = \"" + type + "\"";
        sqlCommand += " ORDER BY 'Time' DESC;";
        System.out.println(sqlCommand);
        ResultSet rs = this.exec(sqlCommand);

        ArrayList<SensorData> data = new ArrayList<>();
        if (rs != null) {
            while (rs.next()) {
                int zone = rs.getInt("Zone");
                int value = rs.getInt("Value");
                data.add(new SensorData(zone, type, value));
            }
        } 
        return data.toArray(new SensorData[data.size()]);       
    }

    public SensorData[] resuestSensorData(String type, int zone) throws SQLException {
        String sqlCommand = "SELECT * FROM '" + table + "' WHERE ";
        sqlCommand += "\"Data Type\" = \"" + type + "\"";
        sqlCommand += "AND Zone = " + zone;
        sqlCommand += " ORDER BY 'Time' DESC;";
        ResultSet rs = this.exec(sqlCommand);

        ArrayList<SensorData> data = new ArrayList<>();
        while (rs.next()) {
            int value = rs.getInt("Value");
            data.add(new SensorData(zone, type, value));
        }
        return data.toArray(new SensorData[data.size()]);
    }
    
    //DO NOT CHANGE
    static Connection sqlite = null;

    /**
     * @return a connection to the sqlite database created from your DDL sql script
     * @throws SQLException
     */
    public  Connection sqliteConn() throws SQLException {
        if (sqlite == null || sqlite.isClosed()) {
            try {
                Class.forName("org.sqlite.JDBC");
                sqlite = DriverManager.getConnection("jdbc:sqlite:databases/database.db");
                System.out.println("Opened database successfully");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return sqlite;
    }

    


    /**
     * executes one or more sql commands. 
     * The commands are seperated by ;
     * For this assignment, we confirm that no data will contain the ; charachter
     * @param batch the string of commands seperated by ;
     * @throws Exception it could all go horribly wrong
     */
    public ResultSet exec(String batch) throws SQLException {
        String[] lines = batch.split(";");
        Connection conn = sqliteConn();
        conn.setAutoCommit(false);
        ResultSet rs = null;
        for (String sql : lines) {
            debug(sql);
            sql=sql.trim();
            try{
                Statement stmt = conn.createStatement();
                rs = stmt.executeQuery(sql); 
            } catch (Exception e){
                //don't use Log4j!!!!!
                if (debug) {e.printStackTrace();}
            }
        }
        try{
        conn.commit();//this could really throw an exception if the data violates constraints
        } catch (Exception e){
            try{
            conn.rollback();
            } catch (Exception r){
                debug(r.getLocalizedMessage());
            }
            debug(e.getLocalizedMessage());
        }
        try {
        conn.setAutoCommit(true);
    } catch (Exception f) {
        if (!conn.isClosed()) {
            conn.close();
        }
    }
    return rs;
    }

    private void debug(String txt) {
        if (debug){
            System.out.println(txt);
        }
    }

        /**
     * Method to find the names of attributes in  a resultset
     * @param rs a result set
     * @return a list of names of attributes using in the resultset
     */
    public List<String> attributeNamesofResultSet(ResultSet rs){
        List<String> result = new ArrayList<>();
        
        try {
            ResultSetMetaData rsmd = rs.getMetaData();
            int n=rsmd.getColumnCount();
            for (int i=1;i<=n;i++){
                result.add(rsmd.getColumnName(i));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    
}
