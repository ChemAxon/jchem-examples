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
		final long queriesRun = pc.getOutputLines().stream().filter(line -> line.contains("Result count: ")).count();
		assertThat(queriesRun, Matchers.is(2L));
	}

    @AfterEach
    void resetOutputStream() {
        MultipleQueriesExample.out = System.out;
    }

}
