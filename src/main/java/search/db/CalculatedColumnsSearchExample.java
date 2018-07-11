package search.db;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import resource.ResourceLocator;
import util.ConnectionUtil;
import util.MolImportUtil;
import util.SearchUtil;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.jchem.db.StructureTableOptions;
import chemaxon.jchem.db.TableTypeConstants;
import chemaxon.jchem.db.UpdateHandler;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example code showing the usage of calculated columns during search.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class CalculatedColumnsSearchExample {

    private static final String TABLE_NAME = "demo";

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new CalculatedColumnsSearchExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            System.out.print("Setting up molecule table... ");

            createTable();
            MolImportUtil.databaseImport(ResourceLocator.getDefaultInputPath(), connHandler,
                    TABLE_NAME);

            System.out.println("Done.");
            System.out.println();

            search();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void createTable() throws SQLException {

        // Drop the table if it already exists
        if (UpdateHandler.isStructureTable(connHandler, TABLE_NAME)) {
            UpdateHandler.dropStructureTable(connHandler, TABLE_NAME);
        }

        // Create the table
        StructureTableOptions tableOptions = getStructureTableOptions(TABLE_NAME);
        UpdateHandler.createStructureTable(connHandler, tableOptions);
    }

    private StructureTableOptions getStructureTableOptions(String tableName) {

        final StructureTableOptions tableOptions =
                new StructureTableOptions(tableName, TableTypeConstants.TABLE_TYPE_MOLECULES);
        tableOptions.setExtraColumnDefinitions(", logp  numeric(30,15), "
                + "rtbl_bnd_cnt numeric(1,0), " + "pka_ac_2  numeric(30,15)");

        Map<String, String> chemTermMap = new HashMap<String, String>();
        chemTermMap.put("logP", "logP()");
        chemTermMap.put("rtbl_bnd_cnt", "rotatableBondCount()>4");
        chemTermMap.put("pka_ac_2", "pKa(\"acidic\", \"2\")");
        tableOptions.setChemTermColsConfig(chemTermMap);

        return tableOptions;
    }

    private void search() throws Exception {
        String query = "CCC1C=CC=CC=1";

        // Init searcher
        JChemSearchOptions searchOpts =
                new JChemSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
        JChemSearch jcs =
                SearchUtil.createJChemSearch(connHandler, query, TABLE_NAME, searchOpts);

        searchOpts = jcs.getSearchOptions();
        String[] columns = { "logp", "rtbl_bnd_cnt", "pka_ac_2" };
        double[] thresholds = { 3.85, 3, 18 };

        for (int i = 0; i < columns.length; i++) {
            // e.g. SELECT cd_id FROM search_example WHERE logp>0,3
            searchOpts.setFilterQuery("SELECT cd_id FROM " + TABLE_NAME + " WHERE "
                    + columns[i] + ">" + thresholds[i]);
            jcs.run();
            int[] cdIDs = jcs.getResults();
            System.out.println("Results using " + columns[i]);
            SearchUtil.printSearchResults(cdIDs);
        }
    }

}
