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

package search.hitdisplay;

import java.util.Arrays;

import resource.ResourceLocator;
import util.ConnectionUtil;
import util.DisplayUtil;
import util.MolImportUtil;
import util.SearchUtil;
import util.TableOperations;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.struc.Molecule;
import chemaxon.util.ConnectionHandler;
import chemaxon.util.HitColoringAndAlignmentOptions;

/**
 * This example demonstrates how to retrieve search results rotated according to the query.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class RotateDatabaseHitsExample {

    private static final String TABLE_NAME = "demo";

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new RotateDatabaseHitsExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            TableOperations.setupMoleculeTable(connHandler, TABLE_NAME);
            runExample();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }

    }

    private void runExample() throws Exception {
        Molecule[] hits = null;

        JChemSearchOptions searchOpts =
                new JChemSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, "OC(CCC)=O", TABLE_NAME, searchOpts);

        String path = ResourceLocator.getPath("rotateQuery.mrv");
        Molecule query = MolImportUtil.importMol(path);
        jcs.setQueryStructure(query);

        jcs.run();

        HitColoringAndAlignmentOptions displayOpts = DisplayUtil.createColoringOptions();
        displayOpts.setAlignmentMode(HitColoringAndAlignmentOptions.ALIGNMENT_ROTATE);

        // HitDisplayTool is integrated in JChemSearch
        int[] results = jcs.getResults();
        System.out.println("Hits: " + Arrays.toString(results));
        hits = jcs.getHitsAsMolecules(results, displayOpts, null, null);

        // Show query
        DisplayUtil.showMolecule(query, 0, 200, "Query");

        // Showing first 8 hits
        for (int i = 0; i < 8; i++) {
            DisplayUtil.showMolecule(hits[i], i + 4, 200, "Hit " + (i + 1));
        }
    }

}
