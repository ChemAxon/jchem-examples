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

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import util.ConnectionUtil;
import util.TableOperations;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * This class demonstrates two different approaches to retrieve the intersection of the result
 * of multiple queries (logical AND operation).
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class MultipleQueriesExample {

    private static final String TABLE_NAME = "demo";

    private static final String[] QUERIES = new String[] { "CCCCC", "O", "N" };

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new MultipleQueriesExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            TableOperations.setupMoleculeTable(connHandler, TABLE_NAME);
            warmupSearch();
            runNormalQueries();
            runFilteredQueries();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    /**
     * Executes the queries separately and calculates the intersection of the returned cd_ids
     * "manually".
     */
    private void runNormalQueries() throws Exception {

        System.out.println("Running normal queries");

        long start = System.currentTimeMillis();

        Set<Integer> results = new TreeSet<Integer>(getSearchHits(QUERIES[0]));
        results.retainAll(getSearchHits(QUERIES[1]));
        results.retainAll(getSearchHits(QUERIES[2]));

        System.out.println("Final results:");
        System.out.println("Elapsed time (in ms): " + (System.currentTimeMillis() - start));
        listResults(results);
    }

    /**
     * Executes the queries with passing the cd_ids of the result of the previous query to the
     * next JChem search as filter criterion.
     */
    private void runFilteredQueries() throws Exception {

        System.out.println("Running filtered queries");

        long start = System.currentTimeMillis();
        Collection<Integer> results = getSearchHits(QUERIES[0]);
        results = getFilteredSearchHits(QUERIES[1], results);
        results = getFilteredSearchHits(QUERIES[2], results);

        System.out.println("Final results:");
        System.out.println("Elapsed time (in ms): " + (System.currentTimeMillis() - start));
        listResults(results);
    }

    /**
     * Get hits for a database search without filter ids.
     * 
     * @param query the query string
     * @return the cd_ids of the matching targets
     * @throws Exception
     */
    private Collection<Integer> getSearchHits(String query) throws Exception {
        return getFilteredSearchHits(query, null);
    }

    /**
     * Warmup search to load structure cache.
     */
    private void warmupSearch() throws Exception {
        System.out.println("Warmup search...");
        getSearchHits("");
    }

    /**
     * Get hits for a database search with filter ids.
     * 
     * @param query the query string
     * @param cd_ids the ids to use as filter, search will be performed only on molecules with
     *            these ids
     * @return the cd_ids of the matching targets
     * @throws Exception
     */
    private Collection<Integer> getFilteredSearchHits(String query,
            Collection<Integer> filterIds) throws Exception {

        // Create options and searcher
        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        JChemSearch jcs = new JChemSearch();
        jcs.setSearchOptions(searchOpts);
        jcs.setConnectionHandler(connHandler);
        jcs.setStructureTable(TABLE_NAME);
        jcs.setQueryStructure(query);
        if (filterIds != null) {
            jcs.setFilterIDList(MultipleQueriesExample.toIntArray(filterIds));
        }

        // Perform search and create results
        jcs.run();
        int[] results = jcs.getResults();
        return MultipleQueriesExample.toIntegerList(results);
    }

    private void listResults(Collection<Integer> results) {
        System.out.printf("Result count: %d\n", results.size());
        System.out.printf("Result cd_ids: %s\n", results.toString());
        System.out.println();
    }

    /**
     * Converts the given int array to an Integer list.
     */
    public static List<Integer> toIntegerList(int[] source) {
        List<Integer> result = new ArrayList<Integer>(source.length);
        for (int i : source) {
            result.add(i);
        }
        return result;
    }

    /**
     * Converts the given collection of Integer objects to int array.
     */
    public static int[] toIntArray(Collection<Integer> source) {
        int[] result = new int[source.size()];
        int i = 0;
        for (Integer x : source) {
            result[i++] = x;
        }
        return result;
    }

}
