package search.db;

import static org.hamcrest.Matchers.startsWith;
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
	public void searchReactantTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(2), startsWith("Hit count: "));
	}

	@Test
	public void searchProductTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(7), startsWith("Hit count: "));
	}

	@Test
	public void searchCoarseReactionTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(12), startsWith("Hit count: "));
	}

	@Test
	public void searchMediumReactionTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(17), startsWith("Hit count: "));
	}

	@After
	public void resetOutputStream() {
		ReactionSimilaritySearchExample.out=System.out;
	}

}
