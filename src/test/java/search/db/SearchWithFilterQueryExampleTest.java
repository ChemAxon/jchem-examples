package search.db;

import static org.hamcrest.Matchers.hasItem;
import static org.junit.Assert.assertThat;

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
		assertThat(pc.getOutputLines(), hasItem("Hit count: 21"));
	}
	
	@After
	public void resetOutputStream() {
		SearchWithFilterQueryExample.out=System.out;
	}
	
}
