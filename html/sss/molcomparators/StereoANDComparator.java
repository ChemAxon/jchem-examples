import chemaxon.sss.search.MolComparator;
import chemaxon.struc.StereoConstants;

/**
 * A wavy bond matches only to another wavy bond 
 * @see <a href="http://www.chemaxon.com/forum/viewpost6379.html">
 * Related topic 1 </a> 
 * @see <a href="http://www.chemaxon.com/forum/viewpost7841.html">
 * Related topic 2 </a> 
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
public final class StereoANDComparator extends MolComparator implements StereoConstants{

    public StereoANDComparator() {
    }

    public boolean compareAtoms(int queryAtom, int targetAtom) {
	// checking implicit H
	int qParity = 0;
	int tParity = 0;
	int q = getOrigQueryAtom(queryAtom);
	if (q >= 0) {
	    qParity = query.getLocalParity(q);
	}
	int t = getOrigTargetAtom(targetAtom);
	if (t >= 0) {
	    tParity = target.getLocalParity(t);
	}

        return !(qParity == PARITY_EITHER && tParity != PARITY_EITHER);
    }

}
