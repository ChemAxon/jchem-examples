package util;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import chemaxon.formats.MolExporter;
import chemaxon.formats.MolFormatException;
import chemaxon.formats.MolImporter;
import chemaxon.jchem.db.Importer;
import chemaxon.jchem.db.TransferException;
import chemaxon.jchem.db.UpdateHandler;
import chemaxon.struc.Molecule;
import chemaxon.util.ConnectionHandler;
import chemaxon.util.MolHandler;

/**
 * Example codes for importing molecules from molecule files or strings into {@link Molecule}
 * objects or database tables.
 * <p>
 * When structures are stored in a file, we can import them into Molecule objects using
 * {@link MolImporter} (e.g. see importMol(), method) or into database using {@link Importer}
 * (see databaseImport() method).
 * <p>
 * If we know only string representation of a structure (SMILES, MDL Molfile, ...), we can
 * import it into a Molecule object using {@link MolImporter} (see importMolFromString()
 * method). importMolFromStringAsQuery() method is useful to import molecules from SMARTS string
 * representation (instead of SMILES).
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class MolImportUtil {

    /***
     * Imports a molecule from a file given by full path.
     * 
     * @param fullPath full path name of file
     * @return first molecule stored in the given file
     * @throws IllegalArgumentException if an error occurs during import
     */
    public static Molecule importMol(String fullPath) {
        try {
            MolImporter mi = new MolImporter(fullPath);
            try {
                return mi.read();
            } finally {
                mi.close();
            }
        } catch (MolFormatException e) {
            throw new IllegalArgumentException("Invalid molecule format", e);
        } catch (IOException e) {
            throw new IllegalArgumentException("Error reading input file", e);
        }
    }

    /**
     * Imports a molecule given by its SMARTS representation.
     * 
     * @param molString molecule string (SMARTS)
     * @return the molecule object
     * @throws IllegalArgumentException if an error occurs during import
     */
    public static Molecule importMolFromStringAsQuery(String molString) {
        try {
            // If queryMode (second parameter) is set true, the input will be interpreted
            // as SMARTS. If SMILES import is needed, set queryMode to false (default).
            MolHandler mh = new MolHandler(molString, true);
            return mh.getMolecule();
        } catch (MolFormatException e) {
            throw new IllegalArgumentException("Invalid molecule format", e);
        }
    }

    /**
     * Imports the content of an input molecule file to a specified structure table in a
     * database.
     * 
     * @param inputFile full path of input file
     * @param connHandler open connection handler
     * @param tableName structure table name
     * @throws TransferException if an error occurs during import
     */
    public static void databaseImport(String inputFile, ConnectionHandler connHandler,
            String tableName) throws TransferException {

        Importer importer = new Importer();

        importer.setInput(inputFile);
        importer.setConnectionHandler(connHandler);
        importer.setTableName(tableName);
        importer.setHaltOnError(false);
        // Checking duplicates may slow down import!
        importer.setDuplicateImportAllowed(UpdateHandler.DUPLICATE_FILTERING_OFF);

        // Gather information about file
        importer.init();

        // Import molecules into database table
        importer.importMols();
    }

    /**
     * Imports a single input molecule object to a specified structure table in a database.
     * 
     * @param mol the molecule to import
     * @param connHandler open connection handler
     * @param tableName structure table name
     * @throws Exception if an error occurs during import
     */
    public static void databaseImportFromMolObject(Molecule mol, ConnectionHandler connHandler,
            String tableName) throws Exception {

        UpdateHandler uh =
                new UpdateHandler(connHandler, UpdateHandler.INSERT, tableName, null);
        try {
            // The molecule has to be converted to one of the available formats
            uh.setStructure(MolExporter.exportToFormat(mol, "mrv"));
            uh.execute();
        } finally {
            uh.close();
        }

    }

    /**
     * Imports the content of an input molecule file to a list of Molecule objects.
     * 
     * @param inputFile full path of input file
     * @throws IOException if I/O error occurs during import
     * @throws MolFormatException if the input file contains erroneous structures
     */
    public static List<Molecule> moleculeListImport(String inputFile)
            throws MolFormatException, IOException {

        List<Molecule> molList = new ArrayList<Molecule>();
        MolImporter imp = new MolImporter(inputFile);
        try {
            Molecule mol;
            while ((mol = imp.read()) != null) {
                molList.add(mol);
            }
        } finally {
            imp.close();
        }

        return molList;
    }

}
