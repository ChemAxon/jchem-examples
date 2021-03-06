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

import java.io.PrintStream;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import util.ConnectionUtil;
import util.SearchUtil;
import util.TableOperations;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;
import chemaxon.util.HitColoringAndAlignmentOptions;

/**
 * Example codes for retrieving database fields of hit molecules.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class RetrievingDatabaseFieldsExample {

    private static final String TABLE_NAME = "demo";

    static PrintStream out = System.out;
    
    private ConnectionHandler connHandler;

    public static void main(String[] args) {
        try {
            new RetrievingDatabaseFieldsExample().run();
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

        JChemSearchOptions searchOpts = new JChemSearchOptions(SearchConstants.SUBSTRUCTURE);
        JChemSearch jcs = SearchUtil.createJChemSearch(connHandler, "c1cc(O)c(Br)cc1",
                TABLE_NAME, searchOpts);

        jcs.run();

        // cd_id values of hits
        int[] cdIds = jcs.getResults();

        retrieveFieldsWithSQL(cdIds);
        retrieveFieldsWithJChemSearch(jcs);
    }

    private void retrieveFieldsWithSQL(int[] cdIds) throws SQLException {

        out.println("Retrieving field values " + "with SQL statement.");
        out.println();

        // Specify fields to retrieve, cd_id is (the first) parameter!
        String retrieverSql = "SELECT cd_formula, cd_molweight from " + TABLE_NAME
                + " WHERE cd_id = ?";
        PreparedStatement ps = connHandler.getConnection().prepareStatement(retrieverSql);
        try {
            for (int i = 0; i < cdIds.length; i++) {

                // Set (first) parameter value to cd_id
                int cdId = cdIds[i];
                ps.setInt(1, cdId);

                // Retrieve fields
                ResultSet rs = ps.executeQuery();

                // Display result
                try {
                    if (rs.next()) {
                        out.printf("ID: %d\nFormula: %s\nMass: %.3f\n\n", cdId,
                                rs.getString(1), rs.getDouble(2));
                    } else {
                        // Do nothing, the record may have been deleted in the meantime
                    }
                } finally {
                    rs.close();
                }
            }
        } finally {
            ps.close();
        }
    }

    private void retrieveFieldsWithJChemSearch(JChemSearch jcs) throws Exception {

        out.println("Retrieving field values using JChemSearch.");
        out.println();

        int[] cdIds = jcs.getResults();

        // Specify database fields to retrieve
        ArrayList<String> fieldNames = new ArrayList<String>();
        fieldNames.add("cd_formula");
        fieldNames.add("cd_molweight");

        // ArrayList for returned database field values
        ArrayList<Object[]> fieldValues = new ArrayList<Object[]>();

        // One can also specify coloring and alignment options (not used now)
        HitColoringAndAlignmentOptions displayOpts = null;

        // Retrieve result molecules fieldValues will be also filled!
        jcs.getHitsAsMolecules(cdIds, displayOpts, fieldNames, fieldValues);

        // Print results
        for (int i = 0; i < cdIds.length; i++) {
            String formula = (String) fieldValues.get(i)[0];
            Double mass = (Double) fieldValues.get(i)[1];
            out.printf("ID: %d\nFormula: %s\nMass: %.3f\n\n", cdIds[i], formula, mass);
        }

    }

}
