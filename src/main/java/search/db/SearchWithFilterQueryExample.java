package search.db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Random;

import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example codes for filtering search results based on other (possibly not chemical) database
 * tables.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class SearchWithFilterQueryExample {

    private static final String TABLE_NAME = "demo";

    private static final String STOCK_TABLE_NAME = "stock";
    private static final int MAX_QUANTITY = 10;

    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new SearchWithFilterQueryExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        connHandler = ConnectionUtil.connectToDB();
        try {
            TableOperations.setupMoleculeTable(connHandler, TABLE_NAME);
            createPopulateStockTable(connHandler);
            search();
        } finally {
            ConnectionUtil.closeConnection(connHandler);
        }
    }

    private void search() throws Exception {

        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        JChemSearch jcs = SearchUtil.createJChemSearch(connHandler, "Brc1ccccc1", TABLE_NAME,
                searchOpts);

        jcs.run();
        SearchUtil.printSearchResults(jcs.getResults());

        // Include into the substructure search only the substances of which we have
        // less than 3 (grams) in stock
        jcs.getSearchOptions().setFilterQuery("SELECT cd_id FROM " + STOCK_TABLE_NAME
                + " WHERE quantity < 3");

        jcs.run();
        SearchUtil.printSearchResults(jcs.getResults());
    }

    /**
     * Creates a table which holds the amount in stock for each structure in the structure
     * table. The stock table is created such that it can be joined with the structure table
     * through the cd_id column.
     */
    private void createPopulateStockTable(ConnectionHandler connHandler) throws SQLException {

        System.out.println("Setting up stock table... ");

        Statement stmt = connHandler.getConnection().createStatement();
        try {
            String sql = "DROP TABLE " + STOCK_TABLE_NAME;
            stmt.execute(sql);
        } catch (SQLException sqlException) {
            // The stock table doesn't exist yet
        } finally {
            stmt.close();
        }
        stmt = connHandler.getConnection().createStatement();
        try {
            String sql = "CREATE TABLE " + STOCK_TABLE_NAME
                    + " (cd_id NUMERIC(10,0), quantity NUMERIC(10,2))";
            stmt.execute(sql);
        } finally {
            stmt.close();
        }

        stmt = connHandler.getConnection().createStatement();
        try {
            String sql = "SELECT cd_id FROM " + TABLE_NAME;
            ResultSet rs = stmt.executeQuery(sql);

            Random r = new Random(System.currentTimeMillis());
            String stockPopulatorSql = "INSERT INTO " + STOCK_TABLE_NAME
                    + " (cd_id, quantity) VALUES(?, ?)";
            PreparedStatement ps =
                    connHandler.getConnection().prepareStatement(stockPopulatorSql);
            try {
                while (rs.next()) {
                    int cdId = rs.getInt(1);
                    float qOnStock = r.nextInt(10 * MAX_QUANTITY) / 10F;
                    ps.setInt(1, cdId);
                    ps.setFloat(2, qOnStock);
                    ps.execute();
                }
            } finally {
                rs.close();
                ps.close();
            }
        } finally {
            stmt.close();
        }
    }

}
