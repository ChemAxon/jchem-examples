package search.db;

import static org.junit.Assert.assertThat;

import java.util.List;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;
import chemaxon.jchem.version.JChemVersionInfo;

public class DiverseSelectionExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		DiverseSelectionExample.out = pc.getOutStream();
	}

	@Test
	public void diverseSelectTets() {
		DiverseSelectionExample.main(null);
		List<String> outputLines = pc.getOutputLines();
		//System.out.println(outputLines);

		String[] expectedRepresentatives = JChemVersionInfo.getJChemTableVersion() >= 23050000
				? new String[] { "S(SC1=NC2=C(S1)C=CC=C2)C1=NC2=CC=CC=C2S1", "NC(=O)NNC(=O)NNC(N)=O" }
				: new String[] { "C[N+](C)(C)CC1=CC=CC=C1", "CC(C)CCCC(C)C1CCC2C3CC(Br)C4(Br)CC(Cl)CCC4(C)C3CCC12C" };
		int expectedRepresentativeCount = JChemVersionInfo.getJChemTableVersion() >= 23050000 ? 8 : 10;

		for (String expectedRepresentative : expectedRepresentatives) {
			assertThat(outputLines, Matchers.hasItem("New representative found: " + expectedRepresentative));
		}
		assertThat(outputLines, Matchers.hasItem("Number of representatives: " + expectedRepresentativeCount));
	}

	@After
	public void resetOutputStream() {
		DiverseSelectionExample.out = System.out;
	}
}
