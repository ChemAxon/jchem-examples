package search.db;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class MultipleQueriesExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        MultipleQueriesExample.out = pc.getOutStream();
    }

    @Test
    void searchWithMultipleQueriesTest() {
        MultipleQueriesExample.main(null);
        final long queriesRun = pc.getOutputLines().stream()
                .filter("Result count: 52"::equals)
                .count();
        assertThat(queriesRun).isEqualTo(2L);
    }

    @AfterEach
    void resetOutputStream() {
        MultipleQueriesExample.out = System.out;
    }

}
