package search;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class MemorySearchExampleTest {

    private PrintCollector pc;

    @BeforeEach
    void setMocks() {
        pc = new PrintCollector();
        MemorySearchExample.out = pc.getOutStream();
        MemorySearchExample.err = pc.getErrorStream();
    }

    @Test
    void queryMatches() {
        MemorySearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(1)).as("Should match").isEqualTo("yes");
    }

    @Test
    void thereAre6Hits() {
        MemorySearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(3)).isEqualTo("6");
    }

    @Test
    void thereAre12SensitiveHits() {
        MemorySearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(11)).isEqualTo("12");
    }

    @AfterEach
    void resetToDefault() {
        MemorySearchExample.out = System.out;
        MemorySearchExample.err = System.err;
    }
}
