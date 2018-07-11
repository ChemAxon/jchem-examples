package search.db;

import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example codes for ordering hits of database search.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class SortedSearchExample {

    private static final String TABLE_NAME = "demo";

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new SortedSearchExample().run();
        } catch (Exception e) {
            e.printStackTrace();
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

    private void runSearches() throws Exception {

        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SIMILARITY);

        searchOpts.setDissimilarityThreshold(0.6f);

        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, "c1ccccc1N", TABLE_NAME, searchOpts);

        // Change the default which is by similarity and id:
        jcs.setOrder(JChemSearch.ORDERING_BY_ID);
        jcs.run();

        System.out.printf("%d hit(s) found (in ID order)\n", jcs.getResultCount());
        printResult(jcs);

        jcs.getSearchOptions().setFilterQuery("SELECT cd_id FROM " + TABLE_NAME
                + " ORDER BY cd_molweight");
        jcs.run();
        System.out.println();
        System.out.printf("%d hit(s) found (in molweight order)\n", jcs.getResultCount());
        printResult(jcs);
    }

    private void printResult(JChemSearch jcs) {
        int[] cdIds = jcs.getResults();
        for (int i = 0; i < cdIds.length; i++) {
            int cdId = cdIds[i];
            float dissim = jcs.getDissimilarity(i);
            System.out.printf("cd_id: %d dissimilarity: %.3f\n", cdId, dissim);
        }
    }

}
