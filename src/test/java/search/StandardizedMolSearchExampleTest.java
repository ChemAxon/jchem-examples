package search;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class StandardizedMolSearchExampleTest {

    private PrintCollector pc;
    private final String[] args = new String[]{"hideFrames"};

    @BeforeEach
    void setOutputStream() {
        pc = new PrintCollector();
        StandardizedMolSearchExample.out = pc.getOutStream();
    }

    @Test
    void byDefultThereAreNoMatches() {
        StandardizedMolSearchExample.main(args);
        assertThat(pc.getOutputLines().get(1)).isEqualTo("No match has been found.");
    }

    @Test
    void aromatizedHas3Hits() {
        StandardizedMolSearchExample.main(args);
        assertThat(pc.getOutputLines().get(5)).isEqualTo("There are 3 different hits");
    }

    @Test
    void standardizedMolSearchHas3hits() {
        StandardizedMolSearchExample.main(args);
        assertThat(pc.getOutputLines().get(12)).isEqualTo("There are 3 different hits");
    }

    @AfterEach
    void resetOutputStream() {
        StandardizedMolSearchExample.out = System.out;
    }

}
