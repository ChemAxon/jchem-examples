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

package util;

import java.io.PrintStream;
import java.util.Arrays;
import chemaxon.jchem.db.JChemSearch;
import chemaxon.jchem.db.JChemSearchOptions;
import chemaxon.jchem.util.ConnectionHandler;


/**
 * Example codes for creating and setting a {@link JChemSearch} object that can be used for
 * database search tasks.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class SearchUtil {

    private SearchUtil() throws IllegalAccessException {
        throw new IllegalAccessException("Utility class cannot be instantiated");
    }

    /**
     * Creates a JChemSearch object and fills its main parameters.
     *
     * @param connHandler   open connection handler
     * @param queryStr      string representation of the query structure
     * @param targetTable   name of database table containing the target structures
     * @param searchOptions search options
     * @return JChemSearch object ready for running search
     */
    public static JChemSearch createJChemSearch(final ConnectionHandler connHandler, final String queryStr,
                                                final String targetTable, final JChemSearchOptions searchOptions) {

        final JChemSearch jcs = new JChemSearch();

        jcs.setConnectionHandler(connHandler);
        jcs.setQueryStructure(queryStr);
        jcs.setStructureTable(targetTable);
        jcs.setSearchOptions(searchOptions);

        return jcs;
    }

    /**
     * Prints the given array of CD_IDs to the standard output.
     */
    public static void printSearchResults(final int[] array, final PrintStream out) {
        out.println("Hit count: " + array.length);
        out.println("Hit IDs:   " + Arrays.toString(array));
        out.println();
    }

}
