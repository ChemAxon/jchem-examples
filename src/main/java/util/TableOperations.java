package util;

import java.sql.SQLException;

import resource.ResourceLocator;
import chemaxon.jchem.db.StructureTableOptions;
import chemaxon.jchem.db.TableTypeConstants;
import chemaxon.jchem.db.UpdateHandler;
import chemaxon.util.ConnectionHandler;

/**
 * Example codes for creating structure tables in database.
 * <p>
 * There are mandatory parameters for creating a database table: open connection handler, name
 * of the table to create, and table type.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class TableOperations {

    private static final int LARGE_TABLE_IMPORT_COUNT = 10;

    /**
     * Creates a structure table of type "Molecules". If a table with the same name already
     * exists, it will be dropped first.
     * 
     * @param connHandler an open connection handler
     * @param tableName name of the table to be created
     * @throws SQLException if table cannot be created
     */
    public static void createMoleculeTable(ConnectionHandler connHandler, String tableName)
            throws SQLException {
        createStructureTable(connHandler, tableName, TableTypeConstants.TABLE_TYPE_MOLECULES);
    }

    /**
     * Creates a structure table of the given type. If a table with the same name already
     * exists, it will be dropped first.
     * 
     * @param connHandler an open connection handler
     * @param tableName name of the table to be created
     * @param tableType table type
     * @throws SQLException if table cannot be created
     */
    public static void createStructureTable(ConnectionHandler connHandler, String tableName,
            int tableType) throws SQLException {
        
        // Drop the table if it already exists
        if (UpdateHandler.isStructureTable(connHandler, tableName)) {
            UpdateHandler.dropStructureTable(connHandler, tableName);
        }

        // Create the table
        StructureTableOptions tableOptions = new StructureTableOptions(tableName, tableType);
        UpdateHandler.createStructureTable(connHandler, tableOptions);
    }

    /**
     * Creates a molecule table and loads some structures into it. If a table with the same name
     * already exists, it will be dropped first.
     * 
     * @param connHandler an open connection handler
     * @param tableName name of the table to be created
     * @throws Exception if an error occurs during table creation or molecule import
     */
    public static void setupMoleculeTable(ConnectionHandler connHandler, String tableName)
            throws Exception {

        System.out.print("Setting up default molecule table... ");

        createMoleculeTable(connHandler, tableName);
        MolImportUtil.databaseImport(ResourceLocator.getDefaultInputPath(), connHandler,
                tableName);

        System.out.println("Done.");
        System.out.println();
    }

    /**
     * Creates a molecule table and loads many structures into it. If a table with the same name
     * already exists, it will be dropped first.
     * 
     * @param connHandler an open connection handler
     * @param tableName name of the table to be created
     * @throws Exception if an error occurs during table creation or molecule import
     */
    public static void setupLargeMoleculeTable(ConnectionHandler connHandler, String tableName)
            throws Exception {

        System.out.print("Setting up large molecule table...");

        createMoleculeTable(connHandler, tableName);
        for (int i = 0; i < LARGE_TABLE_IMPORT_COUNT; i++) {
            MolImportUtil.databaseImport(ResourceLocator.getDefaultInputPath(), connHandler,
                    tableName);
            System.out.print(".");
            System.out.flush();
        }

        System.out.println("Done.");
        System.out.println();
    }

}
