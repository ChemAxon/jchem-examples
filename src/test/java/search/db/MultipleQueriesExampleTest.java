package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class MultipleQueriesExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void changeOutputStream() {
        MultipleQueriesExample.out = pc.getOutStream();
    }

    @Test
    public void searchWithMultipleQueriesTest() {
        MultipleQueriesExample.main(null);
        final long queriesRun = pc.getOutputLines().stream().filter("Result count: 52"::equals).count();
        assertThat(queriesRun).isEqualTo(2L);
    }

    @AfterEach
    public void resetOutputStream() {
        MultipleQueriesExample.out = System.out;
    }

}
