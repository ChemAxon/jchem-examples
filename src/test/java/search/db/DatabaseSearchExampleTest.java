package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class DatabaseSearchExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        DatabaseSearchExample.out = pc.getOutStream();
    }

    @Test
    void searchCCNCCHas111Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(1).equals("Hit count: 111"));
    }

    @Test
    void searchCCNPlusCCHas2Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(5).equals("Hit count: 2"));
    }

    @Test
    void searchCCNPlusCCWithChargeIgnoreHas111Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(9).equals("Hit count: 111"));
    }

    @Test
    void searchCCNPlusCCWithChargeIgnoreAndForumlaQueryHas68Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(13).equals("Hit count: 68"));
    }

    @AfterEach
    void resetOutputStream() {
        DatabaseSearchExample.out = System.out;
    }

}
