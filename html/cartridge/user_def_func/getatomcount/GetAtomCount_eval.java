import java.util.StringTokenizer;
import chemaxon.jchem.cartridge.JChemCartEvalModule;

public class GetAtomCount_eval implements JChemCartEvalModule {

    public boolean eval(Object o, String opStr) throws Exception {
	int result = ((Integer)o).intValue();
	boolean isOk = false; 

	StringTokenizer st = new StringTokenizer(opStr, "/");
	String start = st.nextToken();
	String stop = st.nextToken();
	int op = Integer.parseInt(st.nextToken());

	if(stop.equals("null")) {
	    isOk = op == 4 ? result >= Integer.parseInt(start) : 
			     result > Integer.parseInt(start);
	} else if(start.equals("null")) {
	    isOk = op == 8 ? result <= Integer.parseInt(stop) : 
			     result < Integer.parseInt(stop);
	} else {
	    isOk = op == 13 ? result == Integer.parseInt(start) :
		   op == 12 ? result <= Integer.parseInt(stop) && 
			      result >= Integer.parseInt(start) :
		   op == 8  ? result <= Integer.parseInt(stop) && 
			      result > Integer.parseInt(start) :
		   op == 4  ? result < Integer.parseInt(stop) && 
			      result >= Integer.parseInt(start) :
		   result < Integer.parseInt(stop) && 
		   result > Integer.parseInt(start);
	}
	return isOk;
    }
}
