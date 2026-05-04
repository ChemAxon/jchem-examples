package search.db;

import static org.junit.Assert.assertThat;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class CalculatedColumnsSearchExampleTest {

	private final PrintCollector pc = new PrintCollector();

	@Before
	public void setOutputStream() {
		CalculatedColumnsSearchExample.out=pc.getOutStream();
	}

	@Test
	public void logPReturnsWithResult() {
		CalculatedColumnsSearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(2), Matchers.is("Results using logp"));
		assertThat(pc.getOutputLines().get(3), Matchers.startsWith("Hit count: "));
	}

	@Test
	public void rtblBndCountReturnsWithResult() {
		CalculatedColumnsSearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(6), Matchers.is("Results using rtbl_bnd_cnt"));
		assertThat(pc.getOutputLines().get(7), Matchers.startsWith("Hit count: "));
	}

	@Test
	public void pkaAc2ReturnsWithResult() {
		CalculatedColumnsSearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(10), Matchers.is("Results using pka_ac_2"));
		assertThat(pc.getOutputLines().get(11), Matchers.startsWith("Hit count: "));
	}

	@After
	public void resetOutputStream() {
		CalculatedColumnsSearchExample.out=System.out;
	}

}
