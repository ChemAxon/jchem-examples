import chemaxon.sss.search.MolComparator;

/**
 * Atoms should match only when their atom map number is the same 
 * ("Exact" option) or only the target atom has atom map number 
 * ("At least" option).
 * Working mode of comparator can be E ("Exact") or A ("At least")
 * @see <a href="http://www.chemaxon.com/forum/viewpost3401.html">
 * Related topic</a> 
 * @see
 * <a href="http://www.chemaxon.com/jchem/examples/sss/molcomparators/index.html">
 * MolComparator examples </a>
 * @see 
 * <a href="http://www.chemaxon.com/jchem/doc/dev/java/api/chemaxon/sss/search/MolComparator.html">
 * API doc</a>
 * 
 * @author Tamas Csizmazia
 * @since  JChem 5.0
 */
public class AtomMapComparator extends MolComparator{
    
    private String mode = "E";

    /**
     * Constructor: sets working mode
     * @param s mode of Comparator (E or A)
     */
    public AtomMapComparator(String s) {
        if (s.equals("E") || s.equals("A")) {
            mode = s;
        } else {
            warning();
            System.out.println("Mode is set to \"E\"");
        }

    }

    private void warning() {
        System.out.println();
        System.out.println("Trying to set a non-existing mode!");
        System.out.println("Comparator mode should be " +
                "\"E\" or \"A\" (\"exact\" or \"at least\")!");
    }

    public boolean compareAtoms(int queryAtom, int targetAtom) {
	// checking implicit H
	int qmap = 0;
	int q = getOrigQueryAtom(queryAtom);
	if (q >= 0) {
	    qmap = query.getAtom(q).getAtomMap();
	}
	int tmap = 0;
	int t = getOrigTargetAtom(targetAtom);
	if (t >= 0) {
	    tmap = target.getAtom(t).getAtomMap();
	}

        if (qmap == tmap) {
            return true;
        }
        if (mode.equals("A") && (qmap == 0)) {
            return true;
        }
        return false;
    }

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        if (mode.equals("E") || mode.equals("A")) {        
            this.mode = mode;
        } else {
            warning();
            System.out.println("The mode has not changed!");
        }
    }
    
}



