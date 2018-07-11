import chemaxon.util.MolHandler;
import chemaxon.struc.Molecule;
import chemaxon.jchem.cartridge.JChemCartModule;

public class GetAtomCount implements JChemCartModule {

    public Object doFunc(String[] args) throws Exception {
	MolHandler mh = new MolHandler(args[0]);
	return new Integer(mh.getMolecule().getAtomCount());
    }
}
