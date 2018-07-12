package search.db;

import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

@Ignore
public class SimilaritySearchExampleTest {
	private PrintCollector pc = new PrintCollector();
	
	@Before
	public void changeOutputStream() {
		SimilaritySearchExample.out=pc.getOutStream();
	}
	
	@Test
	public void searchReactantTanimotoHas1Hit() {
		SimilaritySearchExample.main(null);
	}
	
	@After
	public void resetOutputStream() {
		SimilaritySearchExample.out=System.out;
	}
}
