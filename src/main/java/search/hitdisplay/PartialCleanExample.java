package search.hitdisplay;

import resource.ResourceLocator;
import util.DisplayUtil;
import util.MolImportUtil;
import chemaxon.formats.MolImporter;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.MolSearchOptions;
import chemaxon.struc.Molecule;
import chemaxon.util.HitColoringAndAlignmentOptions;
import chemaxon.util.HitDisplayTool;

/**
 * Example code for partial clean.
 * 
 * @author JChem Base team, ChemAxon Ltd.
 */
public final class PartialCleanExample {

    public static void main(String[] args) {
        try {
            new PartialCleanExample().run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void run() throws Exception {
        Molecule query = getQuery();
        Molecule target = getTarget();
        Molecule display = getDisplayMol(query, target, getDisplayOptions());

        DisplayUtil.showMolecule(query, 0, "Query");
        DisplayUtil.showMolecule(target, 1, "Target");
        DisplayUtil.showMolecule(display, 2, "Aligned target");
    }

    private HitColoringAndAlignmentOptions getDisplayOptions() {
        HitColoringAndAlignmentOptions displayOpts = DisplayUtil.createColoringOptions();
        displayOpts.setAlignmentMode(HitColoringAndAlignmentOptions.ALIGNMENT_PARTIAL_CLEAN);
        return displayOpts;
    }

    private Molecule getQuery() throws Exception {
        return MolImportUtil.importMol(ResourceLocator.getPath("partialCleanQuery.mrv"));
    }

    private Molecule getTarget() throws Exception {
        return MolImporter.importMol("CC(C)(C)C1=C2OC(=O)C(=C2N2N=NN=C12)C(C)(C)C");
    }

    private Molecule getDisplayMol(Molecule query, Molecule target,
            HitColoringAndAlignmentOptions displayOpts) throws Exception {

        MolSearchOptions searchOpts = new MolSearchOptions(SearchConstants.DEFAULT_SEARCHTYPE);
        HitDisplayTool hdt = new HitDisplayTool(displayOpts, searchOpts, query);

        return hdt.getHit(target);
    }

}
