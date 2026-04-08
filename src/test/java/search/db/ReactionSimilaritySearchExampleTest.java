package search.db;


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
    void searchReactantTanimotoHas1Hit() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(2)).isEqualTo("Hit count: 1");
    }

    @Test
    void searchProductTanimotoHas1Hits() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(7)).isEqualTo("Hit count: 1");
    }

    @Test
    void searchCoarseReactionTanimotoHas6Hits() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(12)).isEqualTo("Hit count: 6");
    }

    @Test
    void searchMediumReactionTanimotoHas5Hits() {
        ReactionSimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(17)).isEqualTo("Hit count: 5");
    }

    @AfterEach
    void resetOutputStream() {
        ReactionSimilaritySearchExample.out = System.out;
    }

}
