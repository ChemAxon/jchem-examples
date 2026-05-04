package search.db;

import static org.junit.Assert.assertThat;
import static org.hamcrest.Matchers.startsWith;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class DatabaseSearchExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		DatabaseSearchExample.out=pc.getOutStream();
	}

	@Test
	public void searchCCNCCReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(1), startsWith("Hit count: "));
	}

	@Test
	public void searchCCNPlusCCReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(5), startsWith("Hit count: "));
	}

	@Test
	public void searchCCNPlusCCWithChargeIgnoreReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(9), startsWith("Hit count: "));
	}

	@Test
	public void searchCCNPlusCCWithChargeIgnoreAndForumlaQueryReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(13), startsWith("Hit count: "));
	}

	@After
	public void resetOutputStream() {
		DatabaseSearchExample.out=System.out;
	}

}
