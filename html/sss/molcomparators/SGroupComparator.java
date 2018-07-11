import chemaxon.sss.search.MolComparator;
import chemaxon.struc.Molecule;
import chemaxon.struc.Sgroup;

/**
 * This comparator takes care of differences between shortcut groups and
 * their ungrouped equivalents
 * @see <a href="http://www.chemaxon.com/forum/viewpost3172.html">
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
public class SGroupComparator extends MolComparator{

    public SGroupComparator() {
    }

    public boolean compareAtoms(int queryAtom, int targetAtom) {
	// checking implicit H
	int q = getOrigQueryAtom(queryAtom);
	if (q < 0) {
	    q = getOrigQueryNeighbour(queryAtom);
	}
	int t = getOrigTargetAtom(targetAtom);
	if (t < 0) {
	    t = getOrigTargetNeighbour(targetAtom);
	}

        String qsgname = getSGroupName(q, query);
        String tsgname = getSGroupName(t, target);
        if (qsgname == null) {
            return (tsgname == null);
        } else {
            return (tsgname == null) ? false : qsgname.equals(tsgname);
        }
    }

    private String getSGroupName(int atom, Molecule mol) {
        Sgroup sg = mol.findSgroupOf(mol.getAtom(atom));
        while (sg != null && sg.getType() != Sgroup.ST_SUPERATOM){
            sg = sg.getParentSgroup();
        }
        return (sg == null ? null : sg.getSubscript());
    }
}
