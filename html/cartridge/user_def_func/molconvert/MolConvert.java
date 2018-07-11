import chemaxon.formats.MolConverter;
import chemaxon.jchem.cartridge.JChemCartModule;
import java.io.*;	

public class MolConvert implements JChemCartModule {

    public Object doFunc(String[] args) throws Exception {
	ByteArrayInputStream bis = new ByteArrayInputStream(args[0].getBytes());
    	ByteArrayOutputStream bout = new ByteArrayOutputStream();
    	MolConverter mc = new MolConverter(bis, bout, args[1], false);
    	mc.convert();
    	return new String(bout.toByteArray());
    }
}
