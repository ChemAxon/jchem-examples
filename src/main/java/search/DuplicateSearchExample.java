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

package search;

import chemaxon.formats.MolExporter;
import chemaxon.formats.MolFormatException;
import chemaxon.search.StandardizedMolSearch;
import chemaxon.search.api.SearchConstants;
import chemaxon.search.api.SearchException;
import chemaxon.search.api.options.MolSearchOptions;
import chemaxon.search.util.HashCode;
import chemaxon.struc.Molecule;
import resource.ResourceLocator;
import util.MolImportUtil;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Running various types of duplicate search:
 * <ul>
 * <li>comparing every pair of molecules</li>
 * <li>comparing smiles format of molecules</li>
 * <li>comparing based on hash-code comparison</li>
 * </ul>
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class DuplicateSearchExample {

    static PrintStream out = System.out;
    static PrintStream err = System.err;

    private static final String MATCHING_IDS = "\tMatching IDs";
    private static final String FOUND_DUPLICATES_MILLIS = "Found %d duplicates in %d milliseconds%n";
    private static final String IS_DUPLICATE_OF = "\t%d is duplicate of %d%n";
    /**
     * Imports molecules from the default input file (1000 structures from NCI data set) and
     * carries out three solution methods of duplicate search on it.
     */
    public static void main(final String[] args) {
        try {
            new DuplicateSearchExample().run();
        } catch (final SearchException e) {
            out.println("Error during duplicate searching.");
            e.printStackTrace(err);
        } catch (final MolFormatException e) {
            out.println("Bad structures in input file.");
            e.printStackTrace(err);
        } catch (final FileNotFoundException e) {
            out.println("Input file couldn't be found");
            e.printStackTrace(err);
        } catch (final IOException e) {
            out.println("I/O error during molecule import.");
            e.printStackTrace(err);
        }
    }

    private void run() throws IOException,
            SearchException {

        out.println("Reading molecules.");
        final String path = ResourceLocator.getDefaultInputPath();
        final List<Molecule> mols = MolImportUtil.moleculeListImport(path);
        for (int i = 0; i < mols.size(); i++) {
            mols.get(i).aromatize();    // aromatization is needed for search!
        }

        // Various duplicate search methods
        searchForDuplicates(mols);
        searchForDuplicatesUniqueSmiles(mols);
        searchForDuplicatesHash(mols);
    }

    /**
     * Performs duplicate search with {@link MolSearchOptions} to compare every pairs of molecules.
     *
     * @param mols molecules to search
     * @throws SearchException if error occurs during duplicate searching
     */
    private void searchForDuplicates(final List<Molecule> mols) throws SearchException {

        final MolSearchOptions searchOptions = new MolSearchOptions(SearchConstants.DUPLICATE);
        final StandardizedMolSearch searcher = new StandardizedMolSearch();
        searcher.setSearchOptions(searchOptions);

        final long start = System.currentTimeMillis();
        out.println();
        out.println("Searching for duplicates.");
        out.println(MATCHING_IDS);

        int num = 0;
        for (int q = 0; q < mols.size(); q++) {
            searcher.setQuery(mols.get(q));
            for (int t = 0; t < q; t++) {
                searcher.setTarget(mols.get(t));
                if (searcher.isMatching()) {
                    out.printf(IS_DUPLICATE_OF, q + 1, t + 1);
                    num++;
                    break;
                }
            }
        }
        out.printf(FOUND_DUPLICATES_MILLIS, num,
                System.currentTimeMillis() - start);
    }

    /**
     * Searches for duplicates based on comparison of the molecules' unique SMILES
     * representation.
     *
     * @param mols molecules to search
     * @throws IOException if error occurs during unique SMILES conversion
     */
    private void searchForDuplicatesUniqueSmiles(final List<Molecule> mols) throws IOException {

        final long start = System.currentTimeMillis();

        out.println();
        out.println("Searching for duplicates based on "
                + "unique SMILES string comparison.");
        out.println(MATCHING_IDS);

        final Set<String> smilesSet = new HashSet<>();
        int num = 0;
        for (int i = 0; i < mols.size(); i++) {
            // Create unique SMILES representation
            final String smiles = MolExporter.exportToFormat(mols.get(i), "smiles:u");
            // Check if the same unique SMILES has already been found
            if (!smilesSet.contains(smiles)) {
                smilesSet.add(smiles);
            } else {
                // Duplicate found: structure is already contained
                out.println("\t" + (i + 1) + " is duplicate.");
                num++;
            }
        }
        out.printf(FOUND_DUPLICATES_MILLIS, num,
                System.currentTimeMillis() - start);
    }

    /**
     * Searches for duplicates based on the comparison of the molecules' hash code. The
     * equivalence of the hash codes doesn't imply a structural equivalence, so molecules with
     * similar hash code should still be matched in structure.
     *
     * @param mols molecules to search
     * @throws SearchException if error occurs during duplicate searching
     */
    private void searchForDuplicatesHash(final List<Molecule> mols) throws SearchException {

        final StandardizedMolSearch searcher = new StandardizedMolSearch();
        final long start = System.currentTimeMillis();
        final HashCode hc = new HashCode();

        // Generate hash codes
        final int[] codes = new int[mols.size()];
        for (int i = 0; i < mols.size(); i++) {
            codes[i] = hc.getHashCode(mols.get(i));
        }

        out.println("\nSearching for duplicates based on "
                + "hash code comparison and subsequent searching");
        out.println(MATCHING_IDS);
        int num = 0;
        for (int q = 0; q < mols.size(); q++) {
            for (int t = 0; t < q; t++) {
                if (codes[q] == codes[t]) {
                    // If hash-codes are equal, check with MolSearch
                    searcher.setQuery(mols.get(q));
                    searcher.setTarget(mols.get(t));
                    if (searcher.isMatching()) {
                        out.printf(IS_DUPLICATE_OF, q + 1, t + 1);
                        num++;
                        break;
                    }
                }
            }
        }
        out.printf(FOUND_DUPLICATES_MILLIS, num,
                System.currentTimeMillis() - start);
    }

}
