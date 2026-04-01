package search.db;


import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class AsyncSearchExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void setOutput() {
        AsyncSearchExample.out = pc.getOutStream();
    }

    @Test
    public void finds210Hits() {
        AsyncSearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().contains("210 hit(s) found."));
    }

    @AfterEach
    public void resetOutput() {
        AsyncSearchExample.out = System.out;
    }

}
