package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class DatabaseSearchExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void changeOutputStream() {
        DatabaseSearchExample.out = pc.getOutStream();
    }

    @Test
    public void searchCCNCCHas111Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(1).equals("Hit count: 111"));
    }

    @Test
    public void searchCCNPlusCCHas2Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(5).equals("Hit count: 2"));
    }

    @Test
    public void searchCCNPlusCCWithChargeIgnoreHas111Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(9).equals("Hit count: 111"));
    }

    @Test
    public void searchCCNPlusCCWithChargeIgnoreAndForumlaQueryHas68Hits() {
        DatabaseSearchExample.main(null);
        assertThat(pc.getOutputLines().get(13).equals("Hit count: 68"));
    }

    @AfterEach
    public void resetOutputStream() {
        DatabaseSearchExample.out = System.out;
    }

}
