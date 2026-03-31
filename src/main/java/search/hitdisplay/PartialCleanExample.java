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

package search.hitdisplay;

import chemaxon.formats.MolImporter;
import chemaxon.search.api.SearchConstants;
import chemaxon.search.api.options.MolSearchOptions;
import chemaxon.search.hitdisplay.HitDisplayOptions;
import chemaxon.search.hitdisplay.HitDisplayTool;
import chemaxon.struc.Molecule;
import resource.ResourceLocator;
import util.DisplayUtil;
import util.MolImportUtil;


/**
 * Example code for partial clean.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class PartialCleanExample {

    private static boolean hideDisplay = false;

    public static void main(final String[] args) {
        hideDisplay = args.length == 1 && "hideDisplay".equals(args[0]);
        try {
            new PartialCleanExample().run();
        } catch (final Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        final Molecule query = getQuery();
        final Molecule target = getTarget();
        final Molecule display = getDisplayMol(query, target, getDisplayOptions());

        if (!hideDisplay) {
            DisplayUtil.showMolecule(query, 0, "Query");
            DisplayUtil.showMolecule(target, 1, "Target");
            DisplayUtil.showMolecule(display, 2, "Aligned target");
        }
    }

    private HitDisplayOptions getDisplayOptions() {
        final HitDisplayOptions displayOpts = DisplayUtil.createColoringOptions();
        displayOpts.setAlignmentMode(HitDisplayOptions.ALIGNMENT_PARTIAL_CLEAN);
        return displayOpts;
    }

    private Molecule getQuery() throws Exception {
        return MolImportUtil.importMol(ResourceLocator.getPath("partialCleanQuery.mrv"));
    }

    private Molecule getTarget() throws Exception {
        return MolImporter.importMol("CC(C)(C)C1=C2OC(=O)C(=C2N2N=NN=C12)C(C)(C)C");
    }

    private Molecule getDisplayMol(final Molecule query, final Molecule target,
                                   final HitDisplayOptions displayOpts) throws Exception {

        final MolSearchOptions searchOpts = new MolSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
        final HitDisplayTool hdt = new HitDisplayTool(displayOpts, searchOpts, query);

        return hdt.getHit(target);
    }

}
