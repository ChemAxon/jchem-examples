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

import chemaxon.jchem.db.JChemSearch;
import chemaxon.jchem.db.JChemSearchOptions;
import chemaxon.jchem.util.ConnectionHandler;
import chemaxon.search.FormulaSearch;
import chemaxon.search.api.SearchConstants;
import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;

import java.io.PrintStream;


/**
 * Example code for searching in database.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DatabaseSearchExample {

    private static final String TABLE_NAME = "demo";
    private static final String SEARCHING = "Searching: ";

    static PrintStream out = System.out;
    static PrintStream err = System.err;

    private ConnectionHandler connHandler;

    public static void main(final String[] args) {
        try {
            new DatabaseSearchExample().run();
        } catch (final Exception e) {
            e.printStackTrace(err);
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            TableOperations.setupMoleculeTable(connHandler, TABLE_NAME);
            runSearches();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void runSearches() {

        // Initialize a JChemSearch object and search options
        final JChemSearch jcs = new JChemSearch();
        jcs.setConnectionHandler(connHandler);
        jcs.setStructureTable(TABLE_NAME);
        String queryStructure = "CCNCC";
        jcs.setQueryStructure(queryStructure);
        final JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        jcs.setSearchOptions(searchOpts);

        out.println(SEARCHING + queryStructure);
        // Execute search and print results
        search(jcs);    // --> several hits

        // Change N to N+ in the query and re-run search
        queryStructure = "CC[N+]CC";
        jcs.setQueryStructure(queryStructure);
        out.println(SEARCHING + queryStructure);
        search(jcs);    // --> only a few hits

        // Change search options to ignore charges
        searchOpts.setChargeMatching(SearchConstants.CHARGE_MATCHING_IGNORE);
        out.println(SEARCHING + queryStructure + " with charge ignore");
        jcs.setSearchOptions(searchOpts);
        search(jcs);    // --> several hits again

        // Note: you can also use getSearchOptions():
        // jcs.getSearchOptions().setChargeMatching(...);

        searchOpts.setFormulaSearchType(FormulaSearch.SUBFORMULA);
        searchOpts.setFormulaSearchQuery("C10N1");
        out.println(SEARCHING + queryStructure
                + " with charge ignore and formula query");
        jcs.setSearchOptions(searchOpts);
        search(jcs);

    }

    /**
     * Runs the database search and lists results.
     */
    private void search(final JChemSearch jcs) {
        try {
            jcs.run();
            final int[] results = jcs.getResults();
            SearchUtil.printSearchResults(results, out);
        } catch (final Exception e) {
            System.err.println("Unexpected error during DB search!");
            e.printStackTrace();
        }
    }

}
