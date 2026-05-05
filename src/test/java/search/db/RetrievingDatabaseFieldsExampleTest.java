package search.db;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class RetrievingDatabaseFieldsExampleTest {

	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		RetrievingDatabaseFieldsExample.out = pc.getOutStream();
	}

	@Test
	public void searchRetrievsFields() {
		RetrievingDatabaseFieldsExample.main(null);
		List<String> lines = pc.getOutputLines();
		assertEquals("These should be found twice", 2, count(lines, "ID: 6"));
		assertEquals("These should be found twice", 2, count(lines, "Formula: C20H10Br2O5"));
		assertEquals("These should be found eight times", 8, count(lines, "Mass: "));
	}

	@After
	public void resetOutputStream() {
		RetrievingDatabaseFieldsExample.out = System.out;
	}

	private int count(List<String> lines, String string) {
		int count = 0;
		for(String l: lines) {
			if(l.contains(string)) {
				++count;
			}
		}
		return count;
	}

}
