package search.hitdisplay;

import resource.ResourceLocator;
import util.DisplayUtil;
import util.MolImportUtil;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.MolSearchOptions;
import chemaxon.struc.Molecule;
import chemaxon.util.HitColoringAndAlignmentOptions;
import chemaxon.util.HitDisplayTool;

/**
 * Example code for showing how to rotate the target molecule to be aligned with the query.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class RotateExample {

    public static void main(String[] args) {
        new RotateExample().run();
    }

    private void run() {
        try {
            runExample();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void runExample() throws Exception {
        Molecule query = getQueryMolecule();
        Molecule target = getTargetMolecule();
        Molecule display = getDisplayMol(query, target, getDisplayOptions());

        DisplayUtil.showMolecule(query, 0, "Query");
        DisplayUtil.showMolecule(target, 1, "Target");
        DisplayUtil.showMolecule(display, 2, "Rotated target");
    }

    private HitColoringAndAlignmentOptions getDisplayOptions() {
        HitColoringAndAlignmentOptions displayOpts = DisplayUtil.createColoringOptions();
        displayOpts.setAlignmentMode(HitColoringAndAlignmentOptions.ALIGNMENT_ROTATE);
        return displayOpts;
    }

    private Molecule getQueryMolecule() {
        return MolImportUtil.importMol(ResourceLocator.getPath("rotateQuery.mrv"));
    }

    private Molecule getTargetMolecule() {
        return MolImportUtil.importMol(ResourceLocator.getPath("rotateTarget.mrv"));
    }

    private Molecule getDisplayMol(Molecule query, Molecule target,
            HitColoringAndAlignmentOptions displayOpts) throws Exception {

        MolSearchOptions searchOpts = new MolSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
        HitDisplayTool hdt = new HitDisplayTool(displayOpts, searchOpts, query);

        return hdt.getHit(target);
    }

}
