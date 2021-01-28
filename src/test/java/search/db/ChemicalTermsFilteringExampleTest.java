package search.db;

import static org.junit.Assert.assertThat;

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
		assertThat(pc.getOutputLines(), Matchers.hasItems("Search has found 121 hits in which O has pka value greater than 2", "Search has found 81 hits in which O has pka value greater than 3.5"));
	}

	@After
	public void resetOutputStream() {
		ChemicalTermsFilteringExample.out = System.out;
	}

}
