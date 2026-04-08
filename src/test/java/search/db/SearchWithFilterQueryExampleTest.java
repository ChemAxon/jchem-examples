package search.db;


import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class SearchWithFilterQueryExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        SearchWithFilterQueryExample.out = pc.getOutStream();
    }

    @Test
    void searchWithFilterQuery() {
        SearchWithFilterQueryExample.main(null);
        assertThat(pc.getOutputLines()).contains("Hit count: 21");
    }

    @AfterEach
    void resetOutputStream() {
        SearchWithFilterQueryExample.out = System.out;
    }

}
