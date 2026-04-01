package search.db;


import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class ReactionSimilaritySearchExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void changeOutputStream() {
        ReactionSimilaritySearchExample.out = pc.getOutStream();
    }

    @Test
    public void searchReactantTanimotoHas1Hit() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(2).equals("Hit count: 1"));
    }

    @Test
    public void searchProductTanimotoHas1Hits() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(7).equals("Hit count: 1"));
    }

    @Test
    public void searchCoarseReactionTanimotoHas6Hits() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(12).equals("Hit count: 6"));
    }

    @Test
    public void searchMediumReactionTanimotoHas5Hits() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(17).equals("Hit count: 5"));
    }

    @AfterEach
    public void resetOutputStream() {
        ReactionSimilaritySearchExample.out = System.out;
    }

}
