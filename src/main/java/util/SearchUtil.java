package util;

import java.util.Arrays;

import chemaxon.jchem.db.JChemSearch;
import chemaxon.sss.search.JChemSearchOptions;
import chemaxon.util.ConnectionHandler;

/**
 * Example codes for creating and setting a {@link JChemSearch} object that can be used for
 * database search tasks.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class SearchUtil {

    /**
     * Creates a JChemSearch object and fills its main parameters.
     * 
     * @param connHandler open connection handler
     * @param queryStr string representation of the query structure
     * @param targetTable name of database table containing the target structures
     * @param searchOptions search options
     * @return JChemSearch object ready for running search
     */
    public static JChemSearch createJChemSearch(ConnectionHandler connHandler, String queryStr,
            String targetTable, JChemSearchOptions searchOptions) {

        JChemSearch jcs = new JChemSearch();

        jcs.setConnectionHandler(connHandler);
        jcs.setQueryStructure(queryStr);
        jcs.setStructureTable(targetTable);
        jcs.setSearchOptions(searchOptions);

        return jcs;
    }

    /**
     * Prints the given array of CD_IDs to the standard output.
     */
    public static void printSearchResults(int[] array) {
        System.out.println("Hit count: " + array.length);
        System.out.println("Hit IDs:   " + Arrays.toString(array));
        System.out.println();
    }

}
