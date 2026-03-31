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

import chemaxon.formats.MolImporter;
import chemaxon.search.MolSearch;
import chemaxon.search.StandardizedMolSearch;
import chemaxon.search.api.options.MolSearchOptions;
import chemaxon.search.hitdisplay.HitDisplayOptions;
import chemaxon.search.hitdisplay.HitDisplayTool;
import chemaxon.struc.Molecule;
import util.DisplayUtil;

import java.io.PrintStream;
import java.util.Arrays;


/**
 * Example codes for demonstrating the difference between {@link MolSearch} and
 * {@link StandardizedMolSearch} classes.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class StandardizedMolSearchExample {

    private static final String QUERY = "Cc1ccccc1";
    private static final String TARGET = "CC1=C(C)C=CC=C1C";
    static PrintStream out = System.out;
    private static boolean hideFrames = false;

    /**
     * Imports the target and query molecule. Checks whether the query matches the target
     * ({@link MolSearch#isMatching()}) and then prints out the different matches twice. First
     * the hits are found with the {@link MolSearch#findFirst()} and the iterative calling of
     * {@link MolSearch#findNext()} methods. Then in one step with the
     * {@link MolSearch#findAll()} method.
     */
    public static void main(final String[] args) {
        try {
            hideFrames = (args.length > 0 && "hideFrames".equals(args[0]));
            new StandardizedMolSearchExample().run();
        } catch (final Exception e) {
            e.printStackTrace();
        }
    }

    private static void displayHits(final Molecule query, final Molecule target,
                                    final MolSearchOptions searchOpts) throws Exception {

        final HitDisplayOptions displayOpts = DisplayUtil.createColoringOptions();

        final HitDisplayTool hdt = new HitDisplayTool(displayOpts, searchOpts, query);
        hdt.setTarget(target);

        int pos = 0;
        Molecule hitMol = null;
        while ((hitMol = hdt.getNextHit()) != null && !hideFrames) {
            DisplayUtil.showMolecule(hitMol, pos++, "Rotated target");
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
        final Molecule query = MolImporter.importMol(QUERY);
        final Molecule target = MolImporter.importMol(TARGET);
        query.aromatize();
        target.aromatize();
        doSearch(new MolSearch(), query, target);
    }

    private void searchWithStandardizedMolSearch() throws Exception {
        out.println("Executing standardized molecule search.");
        doSearch(new StandardizedMolSearch(), MolImporter.importMol(QUERY),
                MolImporter.importMol(TARGET));
    }

    private void doSearch(final MolSearch searcher, final Molecule query, final Molecule target)
            throws Exception {
        searcher.setQuery(query);
        searcher.setTarget(target);
        if (searcher.isMatching()) {
            out.printf("%s is matching %s%n", DisplayUtil.toSmiles(query),
                    DisplayUtil.toSmiles(target));
            out.printf("There are %d different hits%n", searcher.getMatchCount());

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

}
