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

import java.io.PrintStream;
import java.util.Arrays;

import chemaxon.formats.MolImporter;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.MolSearch;
import chemaxon.sss.search.MolSearchOptions;
import chemaxon.sss.search.StandardizedMolSearch;
import chemaxon.struc.Molecule;

/**
 * Example code for demonstrating the usage of {@link MolSearch} class.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class MemorySearchExample {

    private static final String QUERY = "CC";
    private static final String TARGET = "C1CCCCC1";
    
    static PrintStream out = System.out;
    static PrintStream err = System.err;

    public static void main(String[] agrs) {
        try {
            new MemorySearchExample().run();
        } catch (Exception e) {
            err.println("Unexpected error during search!");
            e.printStackTrace(err);
        }
    }

    private void run() throws Exception {

        // Read query and target molecules
        Molecule query = MolImporter.importMol(QUERY);
        Molecule target = MolImporter.importMol(TARGET);

        // Create searcher
        MolSearch searcher = new StandardizedMolSearch();
        searcher.setQuery(query);
        searcher.setTarget(target);

        // Create and set search options
        MolSearchOptions options = new MolSearchOptions(SearchConstants.SUBSTRUCTURE);
        searcher.setSearchOptions(options);

        // Is substructure found?
        out.println("Is query matching target?");
        out.println(searcher.isMatching() ? "yes" : "no");

        // Number of hits
        out.println("Number of hits:");
        out.println(searcher.getMatchCount());
        printHitsWithFindNext(searcher);

        // Order sensitive search
        out.println("Number of order sensitive hits:");
        options.setOrderSensitiveSearch(true);
        searcher.setSearchOptions(options);
        out.println(searcher.getMatchCount());
        printHitsWithFindAll(searcher);
    }

    /**
     * Prints the hits of the specified <code>molSearch</code> with demonstrating the usage of
     * {@link MolSearch#findFirst()} and {@link MolSearch#findNext()} methods.
     * 
     * @param molSearch
     * @throws Exception
     */
    private void printHitsWithFindNext(MolSearch molSearch) throws Exception {
        int[] hit = molSearch.findFirst();
        while (hit != null) {
            out.println(Arrays.toString(hit));
            hit = molSearch.findNext();
        }
    }

    /**
     * Prints the hits of the specified <code>molSearch</code> with demonstrating the usage of
     * {@link MolSearch#findAll()} method.
     * 
     * @param molSearch
     * @throws Exception
     */
    private void printHitsWithFindAll(MolSearch molSearch) throws Exception {
        int[][] allHits = molSearch.findAll();
        if (allHits == null) {
            out.println("No hits has been found.");
            return;
        }
        for (int[] currHit : allHits) {
            out.println(Arrays.toString(currHit));
        }
    }

}
