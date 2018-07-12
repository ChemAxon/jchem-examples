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

import util.DisplayUtil;
import chemaxon.formats.MolImporter;
import chemaxon.sss.search.MolSearch;
import chemaxon.sss.search.MolSearchOptions;
import chemaxon.sss.search.StandardizedMolSearch;
import chemaxon.struc.Molecule;
import chemaxon.util.HitColoringAndAlignmentOptions;
import chemaxon.util.HitDisplayTool;

/**
 * Example codes for demonstrating the difference between {@link MolSearch} and
 * {@link StandardizedMolSearch} classes.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class StandardizedMolSearchExample {

    private static final String QUERY = "Cc1ccccc1";
    private static final String TARGET = "CC1=C(C)C=CC=C1C";
    
    private static boolean hideFrames = false;
    
    static PrintStream out = System.out;

    /**
     * Imports the target and query molecule. Checks whether the query matches the target
     * ({@link MolSearch#isMatching()}) and then prints out the different matches twice. First
     * the hits are found with the {@link MolSearch#findFirst()} and the iterative calling of
     * {@link MolSearch#findNext()} methods. Then in one step with the
     * {@link MolSearch#findAll()} method.
     */
    public static void main(String[] args) {
        try {
        	hideFrames = (args.length > 0 && "hideFrames".equals(args[0]));
            new StandardizedMolSearchExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        searchWithoutAromatization();
        searchWithAromatization();
        searchWithStandardizedMolSearch();
    }

    private void searchWithoutAromatization() throws Exception {
        out.println("Executing molecule search " + "without aromatizing molecules.");
        doSearch(new MolSearch(), MolImporter.importMol(QUERY), MolImporter.importMol(TARGET));
    }

    private void searchWithAromatization() throws Exception {
        out.println("Executing molecule search " + "with aromatized molecules.");
        Molecule query = MolImporter.importMol(QUERY);
        Molecule target = MolImporter.importMol(TARGET);
        query.aromatize();
        target.aromatize();
        doSearch(new MolSearch(), query, target);
    }

    private void searchWithStandardizedMolSearch() throws Exception {
        out.println("Executing standardized molecule search.");
        doSearch(new StandardizedMolSearch(), MolImporter.importMol(QUERY),
                MolImporter.importMol(TARGET));
    }

    private void doSearch(MolSearch searcher, Molecule query, Molecule target)
            throws Exception {
        searcher.setQuery(query);
        searcher.setTarget(target);
        if (searcher.isMatching()) {
            out.printf("%s is matching %s\n", DisplayUtil.toSmiles(query),
                    DisplayUtil.toSmiles(target));
            out.printf("There are %d different hits\n", searcher.getMatchCount());

            int[] hit = searcher.findFirst();
            while (hit != null) {
                out.println(Arrays.toString(hit));
                hit = searcher.findNext();
            }

            displayHits(query, target, searcher.getSearchOptions());

        } else {
            out.println("No match has been found.");
        }
        out.println();
    }

    private static void displayHits(Molecule query, Molecule target,
            MolSearchOptions searchOpts) throws Exception {

        HitColoringAndAlignmentOptions displayOpts = DisplayUtil.createColoringOptions();

        HitDisplayTool hdt = new HitDisplayTool(displayOpts, searchOpts, query);
        hdt.setTarget(target);

        int pos = 0;
        Molecule hitMol = null;
        while ((hitMol = hdt.getNextHit()) != null && !hideFrames) {
            DisplayUtil.showMolecule(hitMol, pos++, "Rotated target");
        }
    }

}
