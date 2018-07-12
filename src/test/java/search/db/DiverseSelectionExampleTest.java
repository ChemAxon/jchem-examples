package search.db;

import static org.junit.Assert.assertThat;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class DiverseSelectionExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		DiverseSelectionExample.out = pc.getOutStream();
	}

	@Test
	public void diverseSelectTets() {
		DiverseSelectionExample.main(null);
		assertThat(pc.getOutputLines(),
				Matchers.hasItems("New representative found: C[N+](C)(C)CC1=CC=CC=C1",
						"New representative found: CC(C)CCCC(C)C1CCC2C3CC(Br)C4(Br)CC(Cl)CCC4(C)C3CCC12C",
						"Number of representatives: 10"));
	}

	@After
	public void resetOutputStream() {
		DiverseSelectionExample.out = System.out;
	}
}
