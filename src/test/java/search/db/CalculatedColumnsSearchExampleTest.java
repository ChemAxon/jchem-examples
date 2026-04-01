package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class CalculatedColumnsSearchExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void setOutputStream() {
        CalculatedColumnsSearchExample.out = pc.getOutStream();
    }

    @Test
    public void logPHas70Hits() {
        CalculatedColumnsSearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(2).equals("Results using logp"));
        assertThat(pc.getOutputLines().get(3).equals("Hit count: 70"));
    }

    @Test
    public void rtblBndCountHas0Hits() {
        CalculatedColumnsSearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(6).equals("Results using rtbl_bnd_cnt"));
        assertThat(pc.getOutputLines().get(7).equals("Hit count: 0"));
    }

    @Test
    public void pkaAc2HasAtLeast6Hits() {
        CalculatedColumnsSearchExample.main(new String[]{});
        assertThat(pc.getOutputLines().get(10).equals("Results using pka_ac_2"));
        assertTrue(Integer.parseInt(pc.getOutputLines().get(11).substring("Hit count: ".length())) >= 6);
    }

    @AfterEach
    public void resetOutputStream() {
        CalculatedColumnsSearchExample.out = System.out;
    }

}
