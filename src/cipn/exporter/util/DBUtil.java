/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cipn.exporter.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author sompr
 */
public class DBUtil {

    private Connection connection;
    private final static DBUtil instance = new DBUtil();

    public static DBUtil getInstance() {
        return instance;
    }

    public Connection getConnection() throws Exception {
        // "jdbc:postgresql://localhost:5432/hos-ce-3?user=postgres&password=postgres"
        String dbUrl = ConfigUtil.getDBUrl();

        if (dbUrl == null || dbUrl.isEmpty()) {
            throw new Exception("No database config.");
        }

        connection = DriverManager.getConnection(dbUrl);

        return connection;
    }

    public boolean testConnection() {
        Connection con;
        try {
            con = getConnection();
        } catch (Exception ex) {
            Logger.getLogger(DBUtil.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
        try (Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery("select CURRENT_DATE")) {
            while (rs.next()) {
                System.out.println(rs.getDate(1));
            }
            return true;
        } catch (SQLException ex) {
            Logger.getLogger(DBUtil.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    public void closeConnection() {
        if (connection == null) {
            return;
        }

        try {
            connection.close();
        } catch (SQLException ex) {
            Logger.getLogger(DBUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
