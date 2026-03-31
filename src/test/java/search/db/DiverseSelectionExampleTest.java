package search.db;

import chemaxon.jchem.version.JChemVersionInfo;
import com.chemaxon.test.helper.PrintCollector;
import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;


public class DiverseSelectionExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @Before
    public void changeOutputStream() {
        DiverseSelectionExample.out = pc.getOutStream();
    }

    @Test
    public void diverseSelectTets() {
        DiverseSelectionExample.main(null);
        final List<String> outputLines = pc.getOutputLines();
        //System.out.println(outputLines);

        final String[] expectedRepresentatives = JChemVersionInfo.getJChemTableVersion() >= 23050000
                ? new String[]{"S(SC1=NC2=C(S1)C=CC=C2)C1=NC2=CC=CC=C2S1", "NC(=O)NNC(=O)NNC(N)=O"}
                : new String[]{"C[N+](C)(C)CC1=CC=CC=C1", "CC(C)CCCC(C)C1CCC2C3CC(Br)C4(Br)CC(Cl)CCC4(C)C3CCC12C"};
        final int expectedRepresentativeCount = JChemVersionInfo.getJChemTableVersion() >= 23050000 ? 8 : 10;

        for (final String expectedRepresentative : expectedRepresentatives) {
            assertThat(outputLines, Matchers.hasItem("New representative found: " + expectedRepresentative));
        }
        assertThat(outputLines, Matchers.hasItem("Number of representatives: " + expectedRepresentativeCount));
    }

    @After
    public void resetOutputStream() {
        DiverseSelectionExample.out = System.out;
    }
}
