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

import chemaxon.jchem.db.JChemSearch;
import chemaxon.jchem.db.JChemSearchOptions;
import chemaxon.jchem.util.ConnectionHandler;
import chemaxon.search.api.SearchConstants;
import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;

import java.io.PrintStream;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Random;


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

    static PrintStream out = System.out;
    static PrintStream err = System.err;

    private ConnectionHandler connHandler;

    public static void main(final String[] args) {
        try {
            new SearchWithFilterQueryExample().run();
        } catch (final Exception e) {
            e.printStackTrace(err);
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

        final JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        final JChemSearch jcs = SearchUtil.createJChemSearch(connHandler, "Brc1ccccc1", TABLE_NAME,
                searchOpts);

        jcs.run();
        SearchUtil.printSearchResults(jcs.getResults(), out);

        // Include into the substructure search only the substances of which we have
        // less than 3 (grams) in stock
        jcs.getSearchOptions().setFilterQuery("SELECT cd_id FROM " + STOCK_TABLE_NAME
                + " WHERE quantity < 3");

        jcs.run();
        SearchUtil.printSearchResults(jcs.getResults(), out);
    }

    /**
     * Creates a table which holds the amount in stock for each structure in the structure
     * table. The stock table is created such that it can be joined with the structure table
     * through the cd_id column.
     */
    private void createPopulateStockTable(final ConnectionHandler connHandler) throws SQLException {

        out.println("Setting up stock table... ");

        try(Statement stmt = connHandler.getConnection().createStatement()) {
            final String sql = "DROP TABLE " + STOCK_TABLE_NAME;
            stmt.execute(sql);
        } catch (final SQLException sqlException) {
            // The stock table doesn't exist yet
        }

        try(Statement stmt = connHandler.getConnection().createStatement()) {
            final String sql = "CREATE TABLE " + STOCK_TABLE_NAME
                    + " (cd_id NUMERIC(10,0), quantity NUMERIC(10,2))";
            stmt.execute(sql);
        }

        try(Statement stmt = connHandler.getConnection().createStatement()){
            final String sql = "SELECT cd_id FROM " + TABLE_NAME;
            try (ResultSet rs = stmt.executeQuery(sql)) {
                final Random r = new Random(System.currentTimeMillis());
                final String stockPopulatorSql = "INSERT INTO " + STOCK_TABLE_NAME
                        + " (cd_id, quantity) VALUES(?, ?)";
                try(PreparedStatement ps =
                            connHandler.getConnection().prepareStatement(stockPopulatorSql)) {
                    while (rs.next()) {
                        final int cdId = rs.getInt(1);
                        final float qOnStock = r.nextInt(10 * MAX_QUANTITY) / 10F;
                        ps.setInt(1, cdId);
                        ps.setFloat(2, qOnStock);
                        ps.execute();
                    }
                }
            }
        }
    }

}
