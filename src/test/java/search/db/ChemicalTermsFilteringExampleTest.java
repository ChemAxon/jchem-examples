package search.db;

import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class ChemicalTermsFilteringExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        ChemicalTermsFilteringExample.out = pc.getOutStream();
    }

    @Test
    void chemicalTermsFilteringTest() {
        ChemicalTermsFilteringExample.main(null);

        final List<String> outputLines = pc.getOutputLines();
        assertThat(extractHitCount(outputLines.get(0))).isGreaterThan(60);
        assertThat(extractHitCount(outputLines.get(1))).isGreaterThan(60);
    }

    private int extractHitCount(final String string) {
        final String hitCountStr = string
                .replaceFirst("Search has found ", "")
                .replaceFirst(" hits in which .* has pka value greater than .*", "");
        return Integer.parseInt(hitCountStr);
    }

    @AfterEach
    void resetOutputStream() {
        ChemicalTermsFilteringExample.out = System.out;
    }

}
