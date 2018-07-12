package search.db;

import static org.junit.Assert.assertThat;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class DatabaseImportExampleTest {
	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		DatabaseImportExample.out = pc.getOutStream();
	}

	@Test
	public void searchReactantTanimotoHas1Hit() {
		DatabaseImportExample.main(null);
		assertThat(pc.getOutputLines(),
				Matchers.hasItem("1000 structures imported"));
	}

	@After
	public void resetOutputStream() {
		DatabaseImportExample.out = System.out;
	}
}
