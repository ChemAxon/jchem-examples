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

    public static void main(String[] args) {
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

        DisplayUtil.showMolecule(query, 0, "Query");
        DisplayUtil.showMolecule(target, 1, "Target");
        DisplayUtil.showMolecule(display, 2, "Colored target");
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
