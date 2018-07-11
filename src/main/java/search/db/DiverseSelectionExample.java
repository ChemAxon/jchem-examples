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

import java.sql.SQLException;

import resource.ResourceLocator;
import util.ConnectionUtil;
import util.TableOperations;
import chemaxon.formats.MolExporter;
import chemaxon.formats.MolImporter;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.jchem.db.UpdateHandler;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.struc.Molecule;
import chemaxon.util.ConnectionHandler;

/**
 * Example code which imports a diverse subset of the input molecules.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DiverseSelectionExample {

    private static final String DIVERSE_MOLECULES_TABLE = "diverse_mols";
    private static final float DISSIM_THRESHOLD = 0.9f;

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new DiverseSelectionExample().run();
        } catch (Exception e) {
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
        MolImporter imp = new MolImporter(ResourceLocator.getDefaultInputPath());
        try {
            Molecule newMol;
            while ((newMol = imp.read()) != null) {
                // Check for similar structures in the database
                if (!similarMoleculeExistsInDB(newMol)) {
                    String smilesMol = MolExporter.exportToFormat(newMol, "smiles");
                    System.out.println("New representative found: " + smilesMol);
                    insertMoleculeIntoDB(smilesMol);
                    count++;
                }
            }
        } finally {
            imp.close();
        }
        System.out.println("Number of representatives: " + count);
    }

    private void insertMoleculeIntoDB(String smilesMolecule) throws SQLException {

        UpdateHandler uh = new UpdateHandler(connHandler, UpdateHandler.INSERT,
                DIVERSE_MOLECULES_TABLE, null);
        try {
            uh.setStructure(smilesMolecule);
            uh.execute();
        } finally {
            uh.close();
        }
    }

    private boolean similarMoleculeExistsInDB(Molecule mol) {
        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SIMILARITY);
        searchOpts.setDissimilarityThreshold(DISSIM_THRESHOLD);

        JChemSearch jcs = new JChemSearch();
        jcs.setConnectionHandler(connHandler);
        jcs.setStructureTable(DIVERSE_MOLECULES_TABLE);
        jcs.setQueryStructure(mol);
        jcs.setSearchOptions(searchOpts);

        try {
            jcs.run();
        } catch (Exception e) {
            System.out.println("Unexpected error during DB search!");
            e.printStackTrace();
        }

        return jcs.getResultCount() > 0;
    }

}
