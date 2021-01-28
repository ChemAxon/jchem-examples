package search.db;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;

import org.hamcrest.Matchers;
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
		assertTrue(getHitAndPkaAboveLimit(outputLines.get(0))>60);
        assertTrue(getHitAndPkaAboveLimit(outputLines.get(1))>60);
		
        assertThat(outputLines, Matchers.hasItems("Search has found 121 hits in which O has pka value greater than 2", "Search has found 81 hits in which O has pka value greater than 3.5"));
	}

	private int getHitAndPkaAboveLimit(String string) {
	    String hitCountStr = 
	            string.replaceFirst("Search has found ", "").replaceFirst(" hits in which .* has pka value greater than .*", "");
        return Integer.valueOf( hitCountStr);
    }

    @After
	public void resetOutputStream() {
		ChemicalTermsFilteringExample.out = System.out;
	}

}
