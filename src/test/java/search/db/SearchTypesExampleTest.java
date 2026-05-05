package search.db;

import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class SearchTypesExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        SearchTypesExample.out = pc.getOutStream();
    }

    @Test
    void searchTypesTest() {
        SearchTypesExample.main(null);
        final List<String> lines = pc.getOutputLines();
        assertThat(lines.get(0)).contains(" hit(s) found");
        assertThat(lines.get(1)).contains(" hit(s) found");
        assertThat(lines.get(2)).contains(" hit(s) found");
    }

    @AfterEach
    void resetOutputStream() {
        SearchTypesExample.out = System.out;
    }

}
