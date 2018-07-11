package search.db;

import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;
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

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new ChemicalTermsFilteringExample().run();
        } catch (Exception e) {
            e.printStackTrace();
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
        System.out.println("Search has found " + jcs.getResultCount()
                + " hits in which O has pka value greater than 2");

        searchOpts.setChemTermsFilter("pka(h(0))> 3.5");
        jcs.setSearchOptions(searchOpts);
        jcs.run();
        System.out.println("Search has found " + jcs.getResultCount()
                + " hits in which O has pka value greater than 3.5");
    }
}
