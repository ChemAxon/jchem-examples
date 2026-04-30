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
		assertThat(outputLines.get(0)).startsWith("Search has found ");
        assertThat(outputLines.get(1)).startsWith("Search has found ");
	}

    @AfterEach
    void resetOutputStream() {
        ChemicalTermsFilteringExample.out = System.out;
    }

}
