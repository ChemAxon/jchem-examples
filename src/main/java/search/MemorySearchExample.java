package search;

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

    public static void main(String[] agrs) {
        try {
            new MemorySearchExample().run();
        } catch (Exception e) {
            System.err.println("Unexpected error during search!");
            e.printStackTrace();
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
        System.out.println("Is query matching target?");
        System.out.println(searcher.isMatching() ? "yes" : "no");

        // Number of hits
        System.out.println("Number of hits:");
        System.out.println(searcher.getMatchCount());
        printHitsWithFindNext(searcher);

        // Order sensitive search
        System.out.println("Number of order sensitive hits:");
        options.setOrderSensitiveSearch(true);
        searcher.setSearchOptions(options);
        System.out.println(searcher.getMatchCount());
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
            System.out.println(Arrays.toString(hit));
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
            System.out.println("No hits has been found.");
            return;
        }
        for (int[] currHit : allHits) {
            System.out.println(Arrays.toString(currHit));
        }
    }

}
