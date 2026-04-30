package search.db;

import org.hamcrest.Matchers;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;

	private final PrintCollector pc = new PrintCollector();

	@BeforeEach
	void changeOutputStream() {
		SearchWithFilterQueryExample.out = pc.getOutStream();
	}

	@Test
	void searchWithFilterQuery() {
		SearchWithFilterQueryExample.main(null);
		assertThat(pc.getOutputLines(), hasItem(Matchers.containsString("Hit count: ")));
	}

	@AfterEach
	void resetOutputStream() {
		SearchWithFilterQueryExample.out = System.out;
	}

}
