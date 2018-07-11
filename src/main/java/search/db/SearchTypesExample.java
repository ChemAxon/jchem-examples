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
