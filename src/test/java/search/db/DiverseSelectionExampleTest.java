package search.db;

import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import chemaxon.jchem.version.JChemVersionInfo;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;


class DiverseSelectionExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        DiverseSelectionExample.out = pc.getOutStream();
    }

    @Test
    void diverseSelectTets() {
        DiverseSelectionExample.main(null);
        final List<String> outputLines = pc.getOutputLines();

        final String[] expectedRepresentatives = JChemVersionInfo.getJChemTableVersion() >= 23050000
                ? new String[]{"S(SC1=NC2=C(S1)C=CC=C2)C1=NC2=CC=CC=C2S1", "NC(=O)NNC(=O)NNC(N)=O"}
                : new String[]{"C[N+](C)(C)CC1=CC=CC=C1", "CC(C)CCCC(C)C1CCC2C3CC(Br)C4(Br)CC(Cl)CCC4(C)C3CCC12C"};
        final int expectedRepresentativeCount = JChemVersionInfo.getJChemTableVersion() >= 23050000 ? 8 : 10;

        for (final String expectedRepresentative : expectedRepresentatives) {
            assertThat(outputLines).contains("New representative found: " + expectedRepresentative);
        }
        assertThat(outputLines).contains("Number of representatives: " + expectedRepresentativeCount);
    }

    @AfterEach
    void resetOutputStream() {
        DiverseSelectionExample.out = System.out;
    }
}
