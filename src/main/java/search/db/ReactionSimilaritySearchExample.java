package search.db;

import java.io.IOException;
import java.sql.SQLException;

import resource.ResourceLocator;
import util.ConnectionUtil;
import util.MolImportUtil;
import util.SearchUtil;
import util.TableOperations;
import chemaxon.jchem.db.DatabaseSearchException;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.jchem.db.TableTypeConstants;
import chemaxon.jchem.db.TransferException;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example code showing the various types of similarity searches on reaction tables.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class ReactionSimilaritySearchExample {

    private static final String REACTION_TABLE = "reactionTable";
    private static final String REACTION_FILE = "hits1_100.smiles";

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new ReactionSimilaritySearchExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            initReactionsTable();
            search();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void search() throws Exception, DatabaseSearchException, SQLException, IOException {

        String query = "[Br:4][C:1]1=[CH:3][CH:6]=[CH:5][S:2]1>>"
                + "[Br:4][C:1]1=[CH:3][CH:6]=[C:5]([S:2]1)N(=O)=O";
        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SIMILARITY);
        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, query, REACTION_TABLE, searchOpts);

        searchOpts = jcs.getSearchOptions();
        float dissimThreshold = (float) 0.3;
        String[] metrics =
                { "ReactantTanimoto", "ProductTanimoto", "CoarseReactionTanimoto",
                        "MediumReactionTanimoto", "StrictReactionTanimoto" };
        for (String m : metrics) {
            System.out.println("Metric: " + m);
            searchOpts.setDissimilarityMetric(m);
            searchOpts.setDissimilarityThreshold(dissimThreshold);
            jcs.run();

            int[] cdIDs = jcs.getResults();
            System.out.println("Results using " + m);
            SearchUtil.printSearchResults(cdIDs);
        }

    }

    private void initReactionsTable() throws IOException, SQLException, TransferException {
        TableOperations.createStructureTable(connHandler, REACTION_TABLE,
                TableTypeConstants.TABLE_TYPE_REACTIONS);
        MolImportUtil.databaseImport(ResourceLocator.getPath(REACTION_FILE), connHandler,
                REACTION_TABLE);
    }

}
