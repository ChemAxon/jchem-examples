package search;

import static org.junit.Assert.assertThat;
import static org.hamcrest.Matchers.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class MemorySearchExampleTest {

	private PrintCollector pc;
	
	@Before
	public void setMocks() {
		pc = new PrintCollector();
		MemorySearchExample.out=pc.getOutStream();
		MemorySearchExample.err=pc.getErrorStream();
	}
	
	@Test
	public void queryMatches() {
		MemorySearchExample.main(new String[] {});
		assertThat("Should match", pc.getOutputLines().get(1), is("yes"));
	}
	
	@Test
	public void thereAre6Hits() {
		MemorySearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(3), is("6"));
	}
	
	@Test
	public void thereAre12SensitiveHits() {
		MemorySearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(11), is("12"));
	}
	
	@After
	public void resetToDefault() {
		MemorySearchExample.out=System.out;
		MemorySearchExample.err=System.err;
	}
}
