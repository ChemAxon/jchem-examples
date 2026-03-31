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

import chemaxon.search.api.SearchConstants;
import chemaxon.search.api.options.MolSearchOptions;
import chemaxon.search.hitdisplay.HitDisplayOptions;
import chemaxon.search.hitdisplay.HitDisplayTool;
import chemaxon.struc.Molecule;
import resource.ResourceLocator;
import util.DisplayUtil;
import util.MolImportUtil;


/**
 * Example code for showing how to rotate the target molecule to be aligned with the query.
 *
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class RotateExample {

    private static boolean hideDisplay = false;

    public static void main(final String[] args) {
        hideDisplay = args.length == 1 && "hideDisplay".equals(args[0]);
        new RotateExample().run();
    }

    private void run() {
        try {
            runExample();
        } catch (final Exception e) {
            e.printStackTrace();
        }
    }

    private void runExample() throws Exception {
        final Molecule query = getQueryMolecule();
        final Molecule target = getTargetMolecule();
        final Molecule display = getDisplayMol(query, target, getDisplayOptions());

        if (!hideDisplay) {
            DisplayUtil.showMolecule(query, 0, "Query");
            DisplayUtil.showMolecule(target, 1, "Target");
            DisplayUtil.showMolecule(display, 2, "Rotated target");
        }
    }

    private HitDisplayOptions getDisplayOptions() {
        final HitDisplayOptions displayOpts = DisplayUtil.createColoringOptions();
        displayOpts.setAlignmentMode(HitDisplayOptions.ALIGNMENT_ROTATE);
        return displayOpts;
    }

    private Molecule getQueryMolecule() {
        return MolImportUtil.importMol(ResourceLocator.getPath("rotateQuery.mrv"));
    }

    private Molecule getTargetMolecule() {
        return MolImportUtil.importMol(ResourceLocator.getPath("rotateTarget.mrv"));
    }

    private Molecule getDisplayMol(final Molecule query, final Molecule target,
                                   final HitDisplayOptions displayOpts) throws Exception {

        final MolSearchOptions searchOpts = new MolSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
        final HitDisplayTool hdt = new HitDisplayTool(displayOpts, searchOpts, query);

        return hdt.getHit(target);
    }

}
