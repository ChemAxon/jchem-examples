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
		assertTrue("These messages should follow each other", followsEachOther(lines, "ID: 6", "Formula: C20H10Br2O5", "Mass: 490.103"));
		assertEquals("These should be found twice", 2, count(lines, "ID: 6"));
		assertEquals("These should be found twice", 2, count(lines, "Formula: C20H10Br2O5"));
		assertEquals("These should be found twice", 2, count(lines, "Mass: 490.103"));
	}

	@After
	public void resetOutputStream() {
		RetrievingDatabaseFieldsExample.out = System.out;
	}
	

	private int count(List<String> lines, String string) {
		int count = 0;
		for(String l: lines) {
			if(l.equals(string)) {
				++count;
			}
		}
		return count;
	}

	private boolean followsEachOther(List<String> lines, String... strs) {
		int previous = lines.indexOf(strs[0]);
		for (int i = 1; i < strs.length; ++i) {
			int idx = lines.indexOf(strs[i]);
			if (idx < 1 || idx != previous + 1) {
				return false;
			}
			previous = idx;
		}
		return previous > 0;
	}

}
