package search.db;

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertThat;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class ReactionSimilaritySearchExampleTest {

	private PrintCollector pc = new PrintCollector();
	
	@Before
	public void changeOutputStream() {
		ReactionSimilaritySearchExample.out=pc.getOutStream();
	}
	
	@Test
	public void searchReactantTanimotoHas1Hit() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(2), is("Hit count: 1"));
	}
	
	@Test
	public void searchProductTanimotoHas1Hits() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(7), is("Hit count: 1"));
	}
	
	@Test
	public void searchCoarseReactionTanimotoHas6Hits() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(12), is("Hit count: 6"));
	}
	
	@Test
	public void searchMediumReactionTanimotoHas5Hits() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(17), is("Hit count: 5"));
	}
	
	@After
	public void resetOutputStream() {
		ReactionSimilaritySearchExample.out=System.out;
	}
	
}
