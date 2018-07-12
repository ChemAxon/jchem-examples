package search.db;

import static org.junit.Assert.assertThat;
import static org.hamcrest.Matchers.is;

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
	public void searchCCNCCHas111Hits() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(1), is("Hit count: 111"));
	}
	
	@Test
	public void searchCCNPlusCCHas2Hits() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(5), is("Hit count: 2"));
	}
	
	@Test
	public void searchCCNPlusCCWithChargeIgnoreHas111Hits() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(9), is("Hit count: 111"));
	}
	
	@Test
	public void searchCCNPlusCCWithChargeIgnoreAndForumlaQueryHas68Hits() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(13), is("Hit count: 68"));
	}
	
	@After
	public void resetOutputStream() {
		DatabaseSearchExample.out=System.out;
	}
	
}
