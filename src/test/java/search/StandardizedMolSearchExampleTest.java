package search;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class StandardizedMolSearchExampleTest {

    private PrintCollector pc;
    private final String[] args = new String[]{"hideFrames"};

    @BeforeEach
    public void setOutputStream() {
        pc = new PrintCollector();
        StandardizedMolSearchExample.out = pc.getOutStream();
    }

    @Test
    public void byDefultThereAreNoMatches() {
        StandardizedMolSearchExample.main(args);
        assertThat(pc.getOutputLines().get(1).equals("No match has been found."));
    }

    @Test
    public void aromatizedHas3Hits() {
        StandardizedMolSearchExample.main(args);
        assertThat(pc.getOutputLines().get(5).equals("There are 3 different hits"));
    }

    @Test
    public void standardizedMolSearchHas3hits() {
        StandardizedMolSearchExample.main(args);
        assertThat(pc.getOutputLines().get(12).equals("There are 3 different hits"));
    }

    @AfterEach
    public void resetOutputStream() {
        StandardizedMolSearchExample.out = System.out;
    }

}
