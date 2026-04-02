package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class DatabaseImportExampleTest {
    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        DatabaseImportExample.out = pc.getOutStream();
    }

    @Test
    void canImport1000Molecules() {
        DatabaseImportExample.main(null);
        assertThat(pc.getOutputLines()).contains("1000 structures imported");
    }

    @AfterEach
    void resetOutputStream() {
        DatabaseImportExample.out = System.out;
    }
}
