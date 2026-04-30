package search.db;

import static org.hamcrest.Matchers.startsWith;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class DatabaseSearchExampleTest {

    private final PrintCollector pc = new PrintCollector();

	@BeforeEach
	void changeOutputStream() {
		DatabaseSearchExample.out = pc.getOutStream();
	}

	@Test
	void searchCCNCCReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(1), startsWith("Hit count: "));
	}

	@Test
	void searchCCNPlusCCReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(5), startsWith("Hit count: "));
	}

	@Test
	void searchCCNPlusCCWithChargeIgnoreReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(9), startsWith("Hit count: "));
	}

	@Test
	void searchCCNPlusCCWithChargeIgnoreAndForumlaQueryReturnsWithResult() {
		DatabaseSearchExample.main(null);
		assertThat(pc.getOutputLines().get(13), startsWith("Hit count: "));
	}

	@AfterEach
	void resetOutputStream() {
		DatabaseSearchExample.out = System.out;
	}

}
