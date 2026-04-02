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
import chemaxon.search.hitdisplay.HitDisplayOptions;
import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;

import java.io.PrintStream;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * Example codes for retrieving database fields of hit molecules.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class RetrievingDatabaseFieldsExample {

    private static final String TABLE_NAME = "demo";

    static PrintStream out = System.out;

    private ConnectionHandler connHandler;

    public static void main(final String[] args) {
        try {
            new RetrievingDatabaseFieldsExample().run();
        } catch (final Exception e) {
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

        final JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        final JChemSearch jcs = SearchUtil.createJChemSearch(connHandler, "c1cc(O)c(Br)cc1",
                TABLE_NAME, searchOpts);

        jcs.run();

        // cd_id values of hits
        final int[] cdIds = jcs.getResults();

        retrieveFieldsWithSQL(cdIds);
        retrieveFieldsWithJChemSearch(jcs);
    }

    private void retrieveFieldsWithSQL(final int[] cdIds) throws SQLException {

        out.println("Retrieving field values " + "with SQL statement.");
        out.println();

        // Specify fields to retrieve, cd_id is (the first) parameter!
        final String retrieverSql = "SELECT cd_formula, cd_molweight from " + TABLE_NAME
                + " WHERE cd_id = ?";
        try(PreparedStatement ps = connHandler.getConnection().prepareStatement(retrieverSql)) {
            for (int i = 0; i < cdIds.length; i++) {

                // Set (first) parameter value to cd_id
                final int cdId = cdIds[i];
                ps.setInt(1, cdId);

                // Retrieve fields
                // Display result
                try(ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out.printf("ID: %d%nFormula: %s%nMass: %.3f%n%n", cdId,
                                rs.getString(1), rs.getDouble(2));
                    } else {
                        // Do nothing, the record may have been deleted in the meantime
                    }
                }
            }
        }
    }

    private void retrieveFieldsWithJChemSearch(final JChemSearch jcs) throws Exception {

        out.println("Retrieving field values using JChemSearch.");
        out.println();

        final int[] cdIds = jcs.getResults();

        // Specify database fields to retrieve
        final ArrayList<String> fieldNames = new ArrayList<>();
        fieldNames.add("cd_formula");
        fieldNames.add("cd_molweight");

        // ArrayList for returned database field values
        final ArrayList<Object[]> fieldValues = new ArrayList<>();

        // One can also specify coloring and alignment options (not used now)
        final HitDisplayOptions displayOpts = null;

        // Retrieve result molecules fieldValues will be also filled!
        jcs.getHitsAsMolecules(cdIds, displayOpts, fieldNames, fieldValues);

        // Print results
        for (int i = 0; i < cdIds.length; i++) {
            final String formula = (String) fieldValues.get(i)[0];
            final Double mass = (Double) fieldValues.get(i)[1];
            out.printf("ID: %d%nFormula: %s%nMass: %.3f%n%n", cdIds[i], formula, mass);
        }
    }
}
