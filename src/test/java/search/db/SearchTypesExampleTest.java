package search.db;

import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;
import com.chemaxon.version.VersionInfo;

public class SearchTypesExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		SearchTypesExample.out = pc.getOutStream();
	}

	@Test
	public void searchTypesTest() {
		SearchTypesExample.main(null);
		List<String> lines = pc.getOutputLines();
		//System.out.println(lines);
		assertContains(lines.get(0), " hit(s) found");
		assertContains(lines.get(1), " hit(s) found");
		assertContains(lines.get(2), " hit(s) found");
	}

	private void assertContains(String line, String contained) {
		assertTrue(line+" should contain "+contained, line.contains(contained));
	}

	@After
	public void resetOutputStream() {
		SearchTypesExample.out = System.out;
	}

}
