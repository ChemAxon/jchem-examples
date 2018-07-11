package util;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Properties;

import chemaxon.jchem.db.SettingsHandler;
import chemaxon.util.ConnectionHandler;

/**
 * Example codes for handling database connections.
 * <p>
 * This class shows two ways of setting database connection properties (JDBC driver, database
 * URL, database user name, password). The first method fills properties according to the given
 * parameters, while the second method loads these settings from the user configuration file
 * (.jchem file).
 * <p>
 * Default location of JChem configuration file:
 * <ul>
 * <li>WINDOWS: %USERPROFILE%\chemaxon\.jchem
 * <li>UNIX/LINUX: ~/.chemaxon/.jchem
 * </ul>
 * <p>
 * Examples of connection settings can be found in the
 * <a href="http://www.chemaxon.com/jchem/doc/admin/JChemBaseFAQ.html#dburl">JChemBase FAQ</a>.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class ConnectionUtil {

    /**
     * Returns a connection handler using the specified parameters.
     * 
     * @param driverClass class name of the database driver
     * @param dbUrl URL of the database
     * @param userName user name for the database
     * @param password password for the database
     * @return initialized connection handler
     */
    public static ConnectionHandler getConnectionHandler(String driverClass, String dbUrl,
            String userName, String password) {

        ConnectionHandler connHandler = new ConnectionHandler();
        connHandler.setDriver(driverClass);
        connHandler.setUrl(dbUrl);
        connHandler.setLoginName(userName);
        connHandler.setPassword(password);

        // The name of the property table could also be changed:
        // connHandler.setPropertyTable("MyPropertyTable");
        // The default value is "JChemProperties".

        return connHandler;
    }

    /**
     * Returns a connection handler using properties defined in user settings (the .jchem
     * configuration file).
     * 
     * @return initialized connection handler
     * @throws IOException if JDBC driver or database URL is missing in the user settings
     */
    public static ConnectionHandler getDefaultConnectionHandler() throws IOException {
        ConnectionHandler connHandler = new ConnectionHandler();
        Properties props = new SettingsHandler().getSettings();
        if (!connHandler.loadValuesFromProperties(props)) {
            // Throw exception only when driver or URL is null
            throw new IOException("Insufficient connection data "
                    + "(JDBC driver or database URL is missing).");
        }
        return connHandler;
    }

    /**
     * Saves the properties of the given connection handler to user settings (the .jchem
     * configuration file).
     * 
     * @param connHandler connection handler
     * @throws IOException if the properties cannot be saved
     */
    public static void saveConnectionProperties(ConnectionHandler connHandler)
            throws IOException {
        Properties props = new Properties();
        connHandler.storeValuesToProperties(props);
        new SettingsHandler().save(props);
    }

    /**
     * Connects to the database specified in the user settings (the .jchem configuration file).
     * 
     * @return the established connection handler
     * @throws IOException if an error occurs during database connection
     */
    public static ConnectionHandler connectToDB() throws IOException {
        try {
            ConnectionHandler connHandler = ConnectionUtil.getDefaultConnectionHandler();
            connHandler.connectToDatabase();
            System.out.println("Connection estabilished to " + connHandler.getUrl());
            return connHandler;
        } catch (Exception e) {
            throw new IOException("Error connecting database", e);
        }
    }

    /**
     * Closes the connection represented by the given connection handler.
     * 
     * @param connHandler connection handler
     */
    public static void closeConnection(ConnectionHandler connHandler) {
        try {
            connHandler.close();
            System.out.println("Connection closed.");
        } catch (SQLException e) {
            System.err.println("Unable to close connection!");
            e.printStackTrace();
        }
    }

}
