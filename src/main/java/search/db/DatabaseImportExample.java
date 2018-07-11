package search.db;

import java.io.IOException;
import java.sql.SQLException;

import resource.ResourceLocator;
import util.ConnectionUtil;
import util.TableOperations;
import chemaxon.formats.MolExporter;
import chemaxon.formats.MolFormatException;
import chemaxon.formats.MolImporter;
import chemaxon.jchem.db.Importer;
import chemaxon.jchem.db.TransferException;
import chemaxon.struc.Molecule;
import chemaxon.util.ConnectionHandler;

/**
 * Example code for importing molecules into database.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DatabaseImportExample {

    private static final String IMPORT_TABLE = "import_test";
    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new DatabaseImportExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            createMoleculeTableInDB();
            listMoleculesToConsole();
            importMoleculesIntoDB();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void createMoleculeTableInDB() throws SQLException {
        TableOperations.createMoleculeTable(connHandler, IMPORT_TABLE);
    }

    /**
     * Lists all molecules found in an input file.
     */
    private void listMoleculesToConsole() throws IOException, MolFormatException {
        MolImporter mi = new MolImporter(ResourceLocator.getDefaultInputPath());
        try {
            int molCount = 0;
            Molecule mol = mi.read();
            while (mol != null) {
                molCount++;
                System.out.printf("Molecule %4d: %s\n", molCount,
                        MolExporter.exportToFormat(mol, "smiles"));
                mol = mi.read();
            }
        } finally {
            mi.close();
        }
    }

    /**
     * Loads all molecules found in an input file
     * 
     * @param ch connection handler to use
     */
    private void importMoleculesIntoDB() throws TransferException {
        System.out.println("\n\nDatabase import:");
        Importer importer = new Importer();

        importer.setConnectionHandler(connHandler);
        importer.setTableName(IMPORT_TABLE);
        importer.setInput(ResourceLocator.getDefaultInputPath());
        importer.init();
        int importedMoleculeCount = importer.importMols();

        System.out.printf("%d structures imported\n", importedMoleculeCount);
    }

}
