package search.db;

import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class CalculatedColumnsSearchExampleTest {

	private PrintCollector pc = new PrintCollector();
	
	@Before
	public void setOutputStream() {
		CalculatedColumnsSearchExample.out=pc.getOutStream();
	}
	
	@Test
	public void logPHas69Hits() {
		CalculatedColumnsSearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(2), Matchers.is("Results using logp"));
		assertThat(pc.getOutputLines().get(3), Matchers.is("Hit count: 69"));
	}
	
	@Test
	public void rtblBndCountHas0Hits() {
		CalculatedColumnsSearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(6), Matchers.is("Results using rtbl_bnd_cnt"));
		assertThat(pc.getOutputLines().get(7), Matchers.is("Hit count: 0"));
	}
	
	@Test
	public void pkaAc2HasAtLeast9Hits() {
		CalculatedColumnsSearchExample.main(new String[] {});
		assertThat(pc.getOutputLines().get(10), Matchers.is("Results using pka_ac_2"));
		assertTrue(Integer.parseInt(pc.getOutputLines().get(11).substring("Hit count: ".length()))>8);
	}
	
	@After
	public void resetOutputStream() {
		CalculatedColumnsSearchExample.out=System.out;
	}
	
}
