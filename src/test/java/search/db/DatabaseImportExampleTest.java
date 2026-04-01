package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class DatabaseImportExampleTest {
    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void changeOutputStream() {
        DatabaseImportExample.out = pc.getOutStream();
    }

    @Test
    public void canImport1000Molecules() {
        DatabaseImportExample.main(null);
        assertThat(pc.getOutputLines().contains("1000 structures imported"));
    }

    @AfterEach
    public void resetOutputStream() {
        DatabaseImportExample.out = System.out;
    }
}
