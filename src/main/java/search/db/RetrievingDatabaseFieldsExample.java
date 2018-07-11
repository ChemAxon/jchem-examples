package search.db;

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

        System.out.println("Retrieving field values " + "with SQL statement.");
        System.out.println();

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
                        System.out.printf("ID: %d\nFormula: %s\nMass: %.3f\n\n", cdId,
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

        System.out.println("Retrieving field values using JChemSearch.");
        System.out.println();

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
            System.out.printf("ID: %d\nFormula: %s\nMass: %.3f\n\n", cdIds[i], formula, mass);
        }

    }

}
