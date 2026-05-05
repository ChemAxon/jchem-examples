package search.db;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class CalculatedColumnsSearchExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void setOutputStream() {
        CalculatedColumnsSearchExample.out = pc.getOutStream();
    }

	@Test
	void logPReturnsWithResult() {
		CalculatedColumnsSearchExample.main(new String[]{});
		assertThat(pc.getOutputLines().get(2)).isEqualTo("Results using logp");
		assertThat(pc.getOutputLines().get(3)).startsWith("Hit count: ");
	}

	@Test
	void rtblBndCountReturnsWithResult() {
		CalculatedColumnsSearchExample.main(new String[]{});
		assertThat(pc.getOutputLines().get(6)).isEqualTo("Results using rtbl_bnd_cnt");
		assertThat(pc.getOutputLines().get(7)).startsWith("Hit count: ");
	}

	@Test
	void pkaAc2ReturnsWithResult() {
		CalculatedColumnsSearchExample.main(new String[]{});
		assertThat(pc.getOutputLines().get(10)).isEqualTo("Results using pka_ac_2");
		assertThat(pc.getOutputLines().get(11)).startsWith("Hit count: ");
	}

    @AfterEach
    void resetOutputStream() {
        CalculatedColumnsSearchExample.out = System.out;
    }

}
