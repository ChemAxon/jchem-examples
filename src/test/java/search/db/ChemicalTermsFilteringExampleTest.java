package search.db;

import static org.junit.Assert.*;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class ChemicalTermsFilteringExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		ChemicalTermsFilteringExample.out = pc.getOutStream();
	}

	@Test
	public void chemicalTermsFilteringTest() {
		ChemicalTermsFilteringExample.main(null);

		List<String> outputLines = pc.getOutputLines();
		assertTrue(outputLines.get(0).startsWith("Search has found "));
        assertTrue(outputLines.get(1).startsWith("Search has found "));
	}

    @After
	public void resetOutputStream() {
		ChemicalTermsFilteringExample.out = System.out;
	}

}
