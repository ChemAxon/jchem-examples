package search.db;

import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example codes for running a search in a separate thread
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class AsyncSearchExample {

    private static final String TABLE_NAME = "largetable";

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new AsyncSearchExample().run();
        } catch (Exception e) {
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
        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, "Brc1ccccc1", TABLE_NAME, searchOpts);

        jcs.setRunMode(JChemSearch.RUN_MODE_ASYNCH_COMPLETE);
        jcs.run();

        while (jcs.isRunning()) {
            String msg = jcs.getProgressMessage();
            int count = jcs.getResultCount();
            System.out.printf("Progress message: %s, result count: %d\n", msg, count);
            Thread.sleep(50);
        }

        System.out.println(jcs.getResultCount() + " hit(s) found.");
    }

}
