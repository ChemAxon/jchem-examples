package search.db;

import static org.junit.Assert.assertThat;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class MultipleQueriesExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		MultipleQueriesExample.out = pc.getOutStream();
	}

	@Test
	public void searchWithMultipleQueriesTest() {
		MultipleQueriesExample.main(null);
		long queriesRun = pc.getOutputLines().stream().filter("Result count: 52"::equals).count();
		assertThat(queriesRun, Matchers.is(2L));
	}

	@After
	public void resetOutputStream() {
		MultipleQueriesExample.out = System.out;
	}

}
