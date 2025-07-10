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
		assertStartsWith(lines.get(0), "21 hit(s) found");
		int expectedSimilarityHitCount = VersionInfo.getJChemTableVersion() >= 23050000 ? 7 : 6;
		assertStartsWith(lines.get(1), expectedSimilarityHitCount+ " hit(s) found");
		assertStartsWith(lines.get(2), "0 hit(s) found");
	}

	private void assertStartsWith(String line, String prefix) {
		assertTrue(line+" should start with "+prefix, line.startsWith(prefix));
	}

	@After
	public void resetOutputStream() {
		SearchTypesExample.out = System.out;
	}
	
}
