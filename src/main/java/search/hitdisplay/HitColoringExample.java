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

import util.DisplayUtil;
import chemaxon.formats.MolImporter;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.MolSearchOptions;
import chemaxon.struc.Molecule;
import chemaxon.util.HitColoringAndAlignmentOptions;
import chemaxon.util.HitDisplayTool;

/**
 * Example code for hit coloring based on similarity search.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class HitColoringExample {

    private static final String QUERY = "N1C=NC2=C1C(=O)N(C)C(=O)N2CCC";
    private static final String TARGET = "CN1C=NC2=C1C(=O)N(C)C(=O)N2OC";
    
    private static boolean hideDisplay = true;

    public static void main(String[] args) {
    	hideDisplay = args.length == 1 && "hideDisplay".equals(args[0]);
        try {
            new HitColoringExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        Molecule query = MolImporter.importMol(QUERY);
        Molecule target = MolImporter.importMol(TARGET);
        Molecule display = getDisplayMol(query, target, getDisplayOptions());

        if(!hideDisplay) {
	        DisplayUtil.showMolecule(query, 0, "Query");
	        DisplayUtil.showMolecule(target, 1, "Target");
	        DisplayUtil.showMolecule(display, 2, "Colored target");
        }
    }

    private HitColoringAndAlignmentOptions getDisplayOptions() {
        HitColoringAndAlignmentOptions displayOpts = DisplayUtil.createColoringOptions();
        displayOpts.setAlignmentMode(HitColoringAndAlignmentOptions.ALIGNMENT_OFF);
        // alignmentOptions.setDisplayLabelsAndBoxes(true);
        // alignmentOptions.setQueryDisplay(true);
        return displayOpts;
    }

    private Molecule getDisplayMol(Molecule query, Molecule target,
            HitColoringAndAlignmentOptions displayOpts) throws Exception {

        MolSearchOptions searchOpts = new MolSearchOptions(SearchConstants.SIMILARITY);
        HitDisplayTool hdt = new HitDisplayTool(displayOpts, searchOpts, query);

        return hdt.getHit(target);
    }

}
