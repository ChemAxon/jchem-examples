package search.db;

import static org.junit.Assert.assertThat;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class AsyncSearchExampleTest {

	private PrintCollector pc = new PrintCollector();
	
	@Before
	public void setOutput() {
		AsyncSearchExample.out=pc.getOutStream();
	}
	
	@Test
	public void finds210Hits() {
		AsyncSearchExample.main(new String[] {});
		assertThat(pc.getOutputLines(), Matchers.hasItem("210 hit(s) found."));
	}
	
	@After
	public void resetOutput() {
		AsyncSearchExample.out=System.out;
	}
	
}
