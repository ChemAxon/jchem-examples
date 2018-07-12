package search;

import static org.hamcrest.Matchers.*;
import static org.junit.Assert.assertThat;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class StandardizedMolSearchExampleTest {

	private PrintCollector pc;
	private String[] args = new String[] {"hideFrames"};
	
	@Before
	public void setOutputStream() {
		pc=new PrintCollector();
		StandardizedMolSearchExample.out=pc.getOutStream();
	}
	
	@Test
	public void byDefultThereAreNoMatches() {
		StandardizedMolSearchExample.main(args);
		assertThat(pc.getOutputLines().get(1), is("No match has been found."));
	}
	
	@Test
	public void aromatizedHas3Hits() {
		StandardizedMolSearchExample.main(args);
		assertThat(pc.getOutputLines().get(5), is("There are 3 different hits"));
	}
	
	@Test
	public void standardizedMolSearchHas3hits() {
		StandardizedMolSearchExample.main(args);
		assertThat(pc.getOutputLines().get(12), is("There are 3 different hits"));
	}
		
	@After
	public void resetOutputStream() {
		StandardizedMolSearchExample.out=System.out;
	}
	
}
