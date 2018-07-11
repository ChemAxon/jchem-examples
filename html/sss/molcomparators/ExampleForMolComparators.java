import chemaxon.formats.MolImporter;
import chemaxon.sss.SearchConstants;
import chemaxon.sss.search.*;
import chemaxon.struc.Molecule;
import chemaxon.util.MolHandler;

import java.io.IOException;

/**
 * This sample program shows three custom MolComparators in work.
 * For more detailed description see 
 * <a href="http://www.chemaxon.com/jchem/examples/sss/molcomparators/index.html">
 * MolComparator examples </a>
 * @author Tamas Csizmazia
 * @since  JChem 5.0
 */
public class ExampleForMolComparators {

    static MolSearch s = new MolSearch();
    static int[][] hits;
    static int i = 0;

    public static void main(String[] args) {
        try {
            
            //****************** Stereo AND ************************//

            echo("********************************");
            echo("* Testing StereoAND comparator *");
            echo("********************************");
            
            MolHandler mh = new MolHandler("ClC1CCCCC1Br");
            Molecule mol1 = mh.getMolecule();
            echo("mol1 = ClC1CCCCC1Br");

            mh = new MolHandler("ClC1CCCC[C@@H]1Br |r|");
            Molecule mol2 = mh.getMolecule();
            echo("mol2 = ClC1CCCC[C@@H]1Br |r|");
            
            mh = new MolHandler("ClC1CCCCC1Br |w:6.7|");
            Molecule mol3 = mh.getMolecule();
            echo("mol3 = ClC1CCCCC1Br |w:6.7|");

            echo("Without comparator");
            
            s.setQuery(mol1);
            s.setTarget(mol2);
            search("Query: mol1, target: mol2");
            
            s.setTarget(mol3);
            search("Query: mol1, target: mol3");
            
            s.setQuery(mol2);
            search("Query: mol2, target: mol3");
            
            s.setQuery(mol3);
            s.setTarget(mol2);
            search("Query: mol3, target: mol2");
            
            StereoANDComparator sac = new StereoANDComparator();
            s.addComparator(sac);
            
            echo("Using comparator");
            
            s.setQuery(mol1);
            s.setTarget(mol2);
            search("Query: mol1, target: mol2");

            s.setTarget(mol3);
            search("Query: mol1, target: mol3");
            
            s.setQuery(mol2);
            search("Query: mol2, target: mol3");
            
            s.setQuery(mol3);
            s.setTarget(mol2);
            search("Query: mol3, target: mol2");
            
            s.removeComparator(sac);
            
            //****************** Atom mapping ************************//

            echo("******************************");
            echo("* Testing AtomMap comparator *");
            echo("******************************");

            mh = new MolHandler("[#7:1]C[#7]");
            mol1 = mh.getMolecule();
            echo("mol1 = [#7:1]C[#7]");
            
            mh = new MolHandler("C1CNC[N:1]C1");
            mol2 = mh.getMolecule();
            echo("mol2 = C1CNC[N:1]C1");
            
            mh = new MolHandler("C1C[N:2]C[N:1]C1");
            mol3 = mh.getMolecule();
            echo("mol3 = C1C[N:2]C[N:1]C1");
            
            echo("Without comparator (using order sensitive search!)");
            MolSearchOptions searchOptions = new MolSearchOptions(SearchConstants.SUBSTRUCTURE);
            searchOptions.setOrderSensitiveSearch(true);
            s.setSearchOptions(searchOptions);
            
            s.setQuery(mol1);
            s.setTarget(mol2);
            search("Query: mol1, target: mol2");

            s.setTarget(mol3);
            search("Query: mol1, target: mol3");

            echo("Exact mode");
            AtomMapComparator amc = new AtomMapComparator("E");
            s.addComparator(amc);
            
            s.setQuery(mol1);
            s.setTarget(mol2);
            search("Query: mol1, target: mol2");

            s.setTarget(mol3);
            search("Query: mol1, target: mol3");

            echo("At least mode");
            amc.setMode("A");
            
            s.setTarget(mol2);
            search("Query: mol1, target: mol2");

            s.setTarget(mol3);
            search("Query: mol1, target: mol3");

            s.removeComparator(amc);
            searchOptions = new MolSearchOptions(SearchConstants.SUBSTRUCTURE);
            searchOptions.setOrderSensitiveSearch(true);
            s.setSearchOptions(searchOptions);
            
            //****************** SGroup search ************************//
            
            echo("*****************************");
            echo("* Testing SGroup comparator *");
            echo("*****************************");

            MolImporter molimp = new MolImporter("SGroupShortcut.mrv");
            		// OR: "SGroupExpanded.mrv"
            try {
                mol1 = molimp.read();
            } finally {
                molimp.close();
            }
            echo("mol1: contains a Ph shortcut group");
            
            molimp = new MolImporter("SGroupUngrouped.mrv");
            mol2 = molimp.read();
            echo("mol2: same as mol1 but the Ph shortcut group is ungrouped");

            echo("Without comparator");
            
            s.setQuery(mol1);
            s.setTarget(mol2);
            search();

            echo("Using comparator");
            SGroupComparator sgc = new SGroupComparator();
            s.addComparator(sgc);
            
            search();
            
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        } catch (SearchException e) {
            e.printStackTrace();
            System.exit(1);
        }//end catch
    }//end main

    private static void search() throws SearchException {
        i++;
        hits = s.findAll();
        System.out.println(i + ". search: ");
        printHits(hits);
    }

    private static void search(String t) throws SearchException {
        System.out.println(t);
        search();
    }

    private static void echo(String s) {
        System.out.println();
        System.out.println(s);
    }

    private static void printHits(int[][] hits) {
        // search all matching substructures and print hits
        if(hits==null)
            System.out.println("\tNo hits");
        else  {
            for(int i=0; i < hits.length; i++) {
                System.out.print("\tHit " + (i+1) + ":  ");
                int[] hit = hits[i];
                for(int j=0; j < hit.length; j++) {
                    System.out.print(hit[j]+" ");
                }
                System.out.println();
            }
        }//end else
    }


}
