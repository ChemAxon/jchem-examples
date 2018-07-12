package search.db;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class SortedSearchExampleTest {

	Pattern pattern = Pattern.compile("(cd_id: )(\\d+)( dissimilarity: )(\\d+\\.\\d+)");
	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		SortedSearchExample.out = pc.getOutStream();
	}

	@Test
	public void search() {
		SortedSearchExample.main(null);
		List<String> lines = pc.getOutputLines();
		assertEquals("7 hit(s) found (in ID order)", lines.get(0));
		assertEquals("7 hit(s) found (in molweight order)", lines.get(9));
		List<String> idOrder = lines.subList(1, 8);
		List<String> mwOrder = lines.subList(10, lines.size());
		assertThat(idOrder, Matchers.hasItems(mwOrder.toArray(new String[] {})));
		assertThat(mwOrder, Matchers.hasItems(idOrder.toArray(new String[] {})));
		List<Integer> ids = idOrder.stream().map(this::toId).collect(Collectors.toList());
		for (int i = 1; i < ids.size(); ++i) {
			assertIntInOrder(ids, i);
		}
		assertTrue("list: " + idOrder + " should not have the same order as list: " + mwOrder,
				notInSameOrder(idOrder, mwOrder));
	}

	@After
	public void resetOutputStream() {
		SortedSearchExample.out = System.out;
	}

	private int toId(String line) {
		return getNum(line, 2);
	}

	private int getNum(String line, int group) {
		Matcher matcher = pattern.matcher(line);
		if (matcher.matches()) {
			return Integer.parseInt(matcher.group(group));
		}
		throw new IllegalStateException("line: \"" + line + "\" should match pattern: \"" + pattern.toString() + "\"");
	}

	private void assertIntInOrder(List<Integer> nums, int idx) {
		assertTrue("in list: " + nums + " [" + idx + "]=" + nums.get(idx) + " should be bigger than [" + (idx - 1)
				+ "]=" + nums.get(idx - 1), nums.get(idx - 1) < nums.get(idx));
	}

	private boolean notInSameOrder(List<String> idOrder, List<String> mwOrder) {
		boolean differentIndexFound = false;
		for (int i = 0; i < mwOrder.size() && !differentIndexFound; ++i) {
			int idx = mwOrder.indexOf(idOrder.get(i));
			differentIndexFound = idx != i;
		}
		return differentIndexFound;
	}
}
