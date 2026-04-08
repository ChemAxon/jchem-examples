/*  Copyright 2018 ChemAxon Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package search.db;

import java.io.IOException;
import java.io.PrintStream;
import java.sql.SQLException;
import resource.ResourceLocator;
import util.ConnectionUtil;
import util.TableOperations;
import chemaxon.formats.MolExporter;
import chemaxon.formats.MolImporter;
import chemaxon.jchem.db.TableImporter;
import chemaxon.jchem.db.exceptions.TableTransferException;
import chemaxon.jchem.util.ConnectionHandler;
import chemaxon.struc.Molecule;

/**
 * Example code for importing molecules into database.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DatabaseImportExample {

    private static final String IMPORT_TABLE = "import_test";
    static PrintStream out = System.out;
    static PrintStream err = System.err;
    private ConnectionHandler connHandler;

    public static void main(final String[] args) {
        try {
            new DatabaseImportExample().run();
        } catch (final Exception e) {
            e.printStackTrace(err);
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
    private void listMoleculesToConsole() throws IOException {
        try(MolImporter mi = new MolImporter(ResourceLocator.getDefaultInputPath())) {
            int molCount = 0;
            Molecule mol = mi.read();
            while (mol != null) {
                molCount++;
                out.printf("Molecule %4d: %s%n", molCount,
                        MolExporter.exportToFormat(mol, "smiles"));
                mol = mi.read();
            }
        }
    }

    /**
     * Loads all molecules found in an input file
     */
    private void importMoleculesIntoDB() throws TableTransferException {
        out.println("\n\nDatabase import:");
        final TableImporter importer = new TableImporter();

        importer.setConnectionHandler(connHandler);
        importer.setTableName(IMPORT_TABLE);
        importer.setInput(ResourceLocator.getDefaultInputPath());
        importer.init();
        final int importedMoleculeCount = importer.importMols();

        out.printf("%d structures imported%n", importedMoleculeCount);
    }

}
