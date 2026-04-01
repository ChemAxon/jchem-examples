package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class ChemicalTermsFilteringExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void changeOutputStream() {
        ChemicalTermsFilteringExample.out = pc.getOutStream();
    }

    @Test
    public void chemicalTermsFilteringTest() {
        ChemicalTermsFilteringExample.main(null);

        final List<String> outputLines = pc.getOutputLines();
        assertTrue(getHitAndPkaAboveLimit(outputLines.get(0)) > 60);
        assertTrue(getHitAndPkaAboveLimit(outputLines.get(1)) > 60);
    }

    private int getHitAndPkaAboveLimit(final String string) {
        final String hitCountStr =
                string.replaceFirst("Search has found ", "").replaceFirst(" hits in which .* has pka value greater than .*", "");
        return Integer.valueOf(hitCountStr);
    }

    @AfterEach
    public void resetOutputStream() {
        ChemicalTermsFilteringExample.out = System.out;
    }

}
