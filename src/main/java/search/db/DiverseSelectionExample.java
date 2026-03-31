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

import chemaxon.formats.MolExporter;
import chemaxon.formats.MolImporter;
import chemaxon.jchem.db.JChemSearch;


import chemaxon.jchem.db.JChemSearchOptions;
import chemaxon.jchem.db.TableUpdateHandler;
import chemaxon.jchem.util.ConnectionHandler;
import chemaxon.search.api.SearchConstants;
import chemaxon.struc.Molecule;

import resource.ResourceLocator;
import util.ConnectionUtil;
import util.TableOperations;

import java.io.PrintStream;
import java.sql.SQLException;

/**
 * Example code which imports a diverse subset of the input molecules.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DiverseSelectionExample {

    private static final String DIVERSE_MOLECULES_TABLE = "diverse_mols";
    private static final float DISSIM_THRESHOLD = 0.9f;

    static PrintStream out = System.out;

    private ConnectionHandler connHandler;

    public static void main(final String[] args) {
        try {
            new DiverseSelectionExample().run();
        } catch (final Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            createDiverseMoleculeTable();
            importDiverseMolecules();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void createDiverseMoleculeTable() throws SQLException {
        TableOperations.createMoleculeTable(connHandler, DIVERSE_MOLECULES_TABLE);
    }

    /**
     * Loops through every molecule in the input file and checks for similar molecule in the
     * structure table
     */
    private void importDiverseMolecules() throws Exception {

        int count = 0;
        try(MolImporter imp = new MolImporter(ResourceLocator.getDefaultInputPath())) {
            Molecule newMol;
            while ((newMol = imp.read()) != null) {
                // Check for similar structures in the database
                if (!similarMoleculeExistsInDB(newMol)) {
                    final String smilesMol = MolExporter.exportToFormat(newMol, "smiles");
                    out.println("New representative found: " + smilesMol);
                    insertMoleculeIntoDB(smilesMol);
                    count++;
                }
            }
        }
        out.println("Number of representatives: " + count);
    }

    private void insertMoleculeIntoDB(final String smilesMolecule) throws SQLException {

        final TableUpdateHandler uh = new TableUpdateHandler(connHandler, TableUpdateHandler.INSERT,
                DIVERSE_MOLECULES_TABLE, null);
        try {
            uh.setStructure(smilesMolecule);
            uh.execute();
        } finally {
            uh.close();
        }
    }

    private boolean similarMoleculeExistsInDB(final Molecule mol) {
        final JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SIMILARITY);
        searchOpts.setDissimilarityThreshold(DISSIM_THRESHOLD);

        final JChemSearch jcs = new JChemSearch();
        jcs.setConnectionHandler(connHandler);
        jcs.setStructureTable(DIVERSE_MOLECULES_TABLE);
        jcs.setQueryStructure(mol);
        jcs.setSearchOptions(searchOpts);

        try {
            jcs.run();
        } catch (final Exception e) {
            out.println("Unexpected error during DB search!");
            e.printStackTrace();
        }

        return jcs.getResultCount() > 0;
    }

}
