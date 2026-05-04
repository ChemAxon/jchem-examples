package search.db;

import static org.hamcrest.Matchers.hasItem;
import static org.junit.Assert.assertThat;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class SearchWithFilterQueryExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		SearchWithFilterQueryExample.out=pc.getOutStream();
	}

	@Test
	public void searchWithFilterQuery() {
		SearchWithFilterQueryExample.main(null);
		assertThat(pc.getOutputLines(), hasItem(Matchers.containsString("Hit count: ")));
	}

	@After
	public void resetOutputStream() {
		SearchWithFilterQueryExample.out=System.out;
	}

}
