package search;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class MemorySearchExampleTest {

    private PrintCollector pc;

    @BeforeEach
    public void setMocks() {
        pc = new PrintCollector();
        MemorySearchExample.out = pc.getOutStream();
        MemorySearchExample.err = pc.getErrorStream();
    }

    @Test
    public void queryMatches() {
        MemorySearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(1)).as("Should match").isEqualTo("yes");
    }

    @Test
    public void thereAre6Hits() {
        MemorySearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(3)).isEqualTo("6");
    }

    @Test
    public void thereAre12SensitiveHits() {
        MemorySearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(11)).isEqualTo("12");
    }

    @AfterEach
    public void resetToDefault() {
        MemorySearchExample.out = System.out;
        MemorySearchExample.err = System.err;
    }
}
