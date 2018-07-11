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

import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;
import chemaxon.descriptors.GenerateMD;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example code showing the creation of descriptor tables together with similarity searching
 * using the measures stored in these descriptor tables. Searching using built-in similarity
 * measures not requiring descriptor tables are also shown.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class SimilaritySearchExample {

    private static final String TABLE_NAME = "similaritySearchTable";
    private static final float DISSIMILARITY_THRESHOLD = 0.65F;
    private static final String[] DESCRIPTORS = { "Pharmacophore", "HDonor", "HAcceptor" };

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new SimilaritySearchExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            TableOperations.setupMoleculeTable(connHandler, TABLE_NAME);
            generateDescriptors();
            performSimpleSimilaritySearch();
            performSimilaritySearchOnDescriptorTable();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    /**
     * Performs similarity search on the chemical hashed fingerprints of the structures. If no
     * descriptor table is set the similarity search is executed on the fingerprint using
     * Tanimoto metrics.
     */
    private void performSimpleSimilaritySearch() throws Exception {
        String query = "C[Si](C)(C)CC1=CC=CC=C1";

        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SIMILARITY);
        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, query, TABLE_NAME, searchOpts);

        searchOpts.setDissimilarityThreshold(DISSIMILARITY_THRESHOLD);
        jcs.setSearchOptions(searchOpts);
        jcs.setQueryStructure(query);

        jcs.run();

        int[] cdIDs = jcs.getResults();
        System.out.println("Results using chemical hashed fingerprint:");
        SearchUtil.printSearchResults(cdIDs);
    }

    /**
     * This function executes similarity search on the descriptor table. Descriptor table is
     * specified by the {@link JChemSearchOptions#setDescriptorName(String)} function.
     * Descriptor tables must be previously generated. In this example code the function
     * {@link #generateDescriptors()} generates them.
     */
    private void performSimilaritySearchOnDescriptorTable() throws Exception {
        String query = "C[Si](C)(C)CC1=CC=CC=C1";

        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SIMILARITY);
        searchOpts.setDissimilarityThreshold(DISSIMILARITY_THRESHOLD);
        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, query, TABLE_NAME, searchOpts);

        for (String desc : DESCRIPTORS) {
            // Adjust search options: select descriptor name
            searchOpts.setDescriptorName(desc);

            jcs.setSearchOptions(searchOpts);
            jcs.setQueryStructure(query);

            jcs.run();

            int[] cdIDs = jcs.getResults();
            String descName = "descriptor: " + desc;
            System.out.println("Results using " + descName);
            SearchUtil.printSearchResults(cdIDs);
        }
    }

    /**
     * Generates the descriptors used for the similarity search.
     * 
     * @throws Exception
     */
    private void generateDescriptors() throws Exception {

        System.out.println("Generating descriptors...");

        // Set connection and table parameters for descriptor generation
        GenerateMD gmd = new GenerateMD(DESCRIPTORS.length);
        gmd.setConnectionHandler(connHandler);
        gmd.setStructureTableName(TABLE_NAME);

        String settings = null;
        // You can see the list of chemaxon implemented descriptor types by entering
        // "generatemd -L" on the console.

        // Set descriptors
        gmd.setDescriptor(0, DESCRIPTORS[0], "PF", settings, null);
        gmd.setDescriptor(1, DESCRIPTORS[1], "HDon", settings, null);
        gmd.setDescriptor(2, DESCRIPTORS[2], "HAcc", settings, null);

        gmd.init();
        gmd.run();
    }

}
