package search.db;

import static org.hamcrest.Matchers.startsWith;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class ReactionSimilaritySearchExampleTest {

	private final PrintCollector pc = new PrintCollector();

	@BeforeEach
	void changeOutputStream() {
		ReactionSimilaritySearchExample.out = pc.getOutStream();
	}

	@Test
	void searchReactantTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(2), startsWith("Hit count: "));
	}

	@Test
	void searchProductTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(7), startsWith("Hit count: "));
	}

	@Test
	void searchCoarseReactionTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(12), startsWith("Hit count: "));
	}

	@Test
	void searchMediumReactionTanimotoReturnsWithResult() {
		ReactionSimilaritySearchExample.main(null);
		assertThat(pc.getOutputLines().get(17), startsWith("Hit count: "));
	}

	@AfterEach
	void resetOutputStream() {
		ReactionSimilaritySearchExample.out = System.out;
	}

}
