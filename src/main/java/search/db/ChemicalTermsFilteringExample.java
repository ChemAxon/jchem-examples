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

import java.io.PrintStream;

import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example code for pre-filtering database hits by calculated chemical terms.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class ChemicalTermsFilteringExample {

    private static final String TABLE_NAME = "demo";

    static PrintStream out = System.out;
    static PrintStream err = System.err;
    
    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new ChemicalTermsFilteringExample().run();
        } catch (Exception e) {
            e.printStackTrace(err);
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            TableOperations.setupMoleculeTable(connHandler, TABLE_NAME);
            search();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }

    }

    private void search() throws Exception {

        JChemSearchOptions searchOpts =
                new JChemSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
        searchOpts.setChemTermsFilter("pka(h(0))> 2");

        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, "OC=O", TABLE_NAME, searchOpts);

        jcs.run();
        out.println("Search has found " + jcs.getResultCount()
                + " hits in which O has pka value greater than 2");

        searchOpts.setChemTermsFilter("pka(h(0))> 3.5");
        jcs.setSearchOptions(searchOpts);
        jcs.run();
        out.println("Search has found " + jcs.getResultCount()
                + " hits in which O has pka value greater than 3.5");
    }
}
