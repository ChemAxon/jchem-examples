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
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example codes for showing consequences of using different search types
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class SearchTypesExample {

    private static final String TABLE_NAME = "demo";

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new SearchTypesExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            runSearches();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void runSearches() throws Exception {
        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        JChemSearch jcs = SearchUtil.createJChemSearch(connHandler, "Brc1ccccc1", TABLE_NAME,
                searchOpts);
        jcs.run();
        printResultMessage(jcs);

        searchOpts = new JChemSearchOptions(SearchConstants.SIMILARITY);
        searchOpts.setDissimilarityThreshold((float) 0.7);
        jcs.setSearchOptions(searchOpts);
        jcs.run();
        printResultMessage(jcs);

        searchOpts = new JChemSearchOptions(SearchConstants.SUPERSTRUCTURE);
        jcs.setSearchOptions(searchOpts);
        jcs.run();
        printResultMessage(jcs);
    }

    private void printResultMessage(JChemSearch search) {
        System.out.printf("%d hit(s) found, %d ms\n", search.getResultCount(),
                search.getSearchTime());
    }

}
