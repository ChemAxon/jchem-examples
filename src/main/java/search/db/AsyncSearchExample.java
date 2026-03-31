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
import chemaxon.search.api.SearchConstants;
import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;

import java.io.PrintStream;


/**
 * Example codes for running a search in a separate thread
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class AsyncSearchExample {

    private static final String TABLE_NAME = "largetable";

    static PrintStream out = System.out;

    private ConnectionHandler connHandler;

    public static void main(final String[] args) {
        try {
            new AsyncSearchExample().run();
        } catch (final Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            // Create large table to have longer search and to see progress
            TableOperations.setupLargeMoleculeTable(connHandler, TABLE_NAME);
            search();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void search() throws Exception {
        final JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        final JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, "Brc1ccccc1", TABLE_NAME, searchOpts);

        jcs.setRunMode(JChemSearch.RUN_MODE_ASYNCH_COMPLETE);
        jcs.run();

        while (jcs.isRunning()) {
            final String msg = jcs.getProgressMessage();
            final int count = jcs.getResultCount();
            out.printf("Progress message: %s, result count: %d%n", msg, count);
            Thread.sleep(50);
        }

        out.println(jcs.getResultCount() + " hit(s) found.");
    }

}
