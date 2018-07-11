package search;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import resource.ResourceLocator;
import util.MolImportUtil;
import chemaxon.formats.MolExporter;
import chemaxon.formats.MolFormatException;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.screen.HashCode;
import chemaxon.sss.search.MolSearch;
import chemaxon.sss.search.MolSearchOptions;
import chemaxon.sss.search.SearchException;
import chemaxon.sss.search.StandardizedMolSearch;
import chemaxon.struc.Molecule;

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

    /**
     * Imports molecules from the default input file (1000 structures from NCI data set) and
     * carries out three solution methods of duplicate search on it.
     */
    public static void main(String[] args) {
        try {
            new DuplicateSearchExample().run();
        } catch (SearchException e) {
            out.println("Error during duplicate searching.");
            e.printStackTrace(err);
        } catch (MolFormatException e) {
            out.println("Bad structures in input file.");
            e.printStackTrace(err);
        } catch (FileNotFoundException e) {
            out.println("Input file couldn't be found");
            e.printStackTrace(err);
        } catch (IOException e) {
            out.println("I/O error during molecule import.");
            e.printStackTrace(err);
        }
    }

    private void run() throws MolFormatException, FileNotFoundException, IOException,
            SearchException {

        out.println("Reading molecules.");
        String path = ResourceLocator.getDefaultInputPath();
        List<Molecule> mols = MolImportUtil.moleculeListImport(path);
        for (int i = 0; i < mols.size(); i++) {
            mols.get(i).aromatize();    // aromatization is needed for search!
        }

        // Various duplicate search methods
        searchForDuplicates(mols);
        searchForDuplicatesUniqueSmiles(mols);
        searchForDuplicatesHash(mols);
    }

    /**
     * Performs duplicate search with {@link MolSearch} to compare every pairs of molecules.
     * 
     * @param mols molecules to search
     * @throws SearchException if error occurs during duplicate searching
     */
    private void searchForDuplicates(List<Molecule> mols) throws SearchException {

        MolSearchOptions searchOptions = new MolSearchOptions(SearchConstants.DUPLICATE);
        StandardizedMolSearch searcher = new StandardizedMolSearch();
        searcher.setSearchOptions(searchOptions);

        long start = System.currentTimeMillis();
        out.println();
        out.println("Searching for duplicates.");
        out.println("\tMatching IDs");

        int num = 0;
        for (int q = 0; q < mols.size(); q++) {
            searcher.setQuery(mols.get(q));
            for (int t = 0; t < q; t++) {
                searcher.setTarget(mols.get(t));
                if (searcher.isMatching()) {
                    out.printf("\t%d is duplicate of %d\n", q + 1, t + 1);
                    num++;
                    break;
                }
            }
        }
        out.printf("Found %d duplicates in %d milliseconds\n", num,
                System.currentTimeMillis() - start);
    }

    /**
     * Searches for duplicates based on comparison of the molecules' unique SMILES
     * representation.
     * 
     * @param mols molecules to search
     * @throws IOException if error occurs during unique SMILES conversion
     */
    private void searchForDuplicatesUniqueSmiles(List<Molecule> mols) throws IOException {

        long start = System.currentTimeMillis();

        out.println();
        out.println("Searching for duplicates based on "
         + "unique SMILES string comparison.");
        out.println("\tMatching IDs");

        Set<String> smilesSet = new HashSet<String>();
        int num = 0;
        for (int i = 0; i < mols.size(); i++) {
            // Create unique SMILES representation
            String smiles = MolExporter.exportToFormat(mols.get(i), "smiles:u");
            // Check if the same unique SMILES has already been found
            if (!smilesSet.contains(smiles)) {
                smilesSet.add(smiles);
            } else {
                // Duplicate found: structure is already contained
                out.println("\t" + (i + 1) + " is duplicate.");
                num++;
            }
        }
        out.printf("Found %d duplicates in %d milliseconds\n", num,
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
    private void searchForDuplicatesHash(List<Molecule> mols) throws SearchException {

        StandardizedMolSearch searcher = new StandardizedMolSearch();
        long start = System.currentTimeMillis();
        HashCode hc = new HashCode();

        // Generate hash codes
        int[] codes = new int[mols.size()];
        for (int i = 0; i < mols.size(); i++) {
            codes[i] = hc.getHashCode(mols.get(i));
        }

        out.println("\nSearching for duplicates based on "
                + "hash code comparison and subsequent searching");
        out.println("\tMatching IDs");
        int num = 0;
        for (int q = 0; q < mols.size(); q++) {
            for (int t = 0; t < q; t++) {
                if (codes[q] == codes[t]) {
                    // If hash-codes are equal, check with MolSearch
                    searcher.setQuery(mols.get(q));
                    searcher.setTarget(mols.get(t));
                    if (searcher.isMatching()) {
                        out.printf("\t%d is duplicate of %d\n", q + 1, t + 1);
                        num++;
                        break;
                    }
                }
            }
        }
        out.printf("Found %d duplicates in %d milliseconds\n", num,
                System.currentTimeMillis() - start);
    }

}
