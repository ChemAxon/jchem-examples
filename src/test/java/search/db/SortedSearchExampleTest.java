package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SortedSearchExampleTest {

    Pattern pattern = Pattern.compile("(cd_id: )(\\d+)( dissimilarity: )(\\d+\\.\\d+)");
    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        SortedSearchExample.out = pc.getOutStream();
    }

    @Test
    void search() {
        SortedSearchExample.main(null);
        final List<String> lines = pc.getOutputLines();
        assertEquals("7 hit(s) found (in ID order)", lines.get(0));
        assertEquals("7 hit(s) found (in molweight order)", lines.get(9));
        final List<String> idOrder = lines.subList(1, 8);
        final List<String> mwOrder = lines.subList(10, lines.size());
        assertThat(idOrder).contains(mwOrder.toArray(new String[]{}));
        assertThat(mwOrder).contains(idOrder.toArray(new String[]{}));
        final List<Integer> ids = idOrder.stream().map(this::toId).collect(Collectors.toList());
        for (int i = 1; i < ids.size(); ++i) {
            assertIntInOrder(ids, i);
        }
        assertTrue(notInSameOrder(idOrder, mwOrder),
                "list: " + idOrder + " should not have the same order as list: " + mwOrder);
    }

    @AfterEach
    void resetOutputStream() {
        SortedSearchExample.out = System.out;
    }

    private int toId(final String line) {
        return getNum(line, 2);
    }

    private int getNum(final String line, final int group) {
        final Matcher matcher = pattern.matcher(line);
        if (matcher.matches()) {
            return Integer.parseInt(matcher.group(group));
        }
        throw new IllegalStateException("line: \"" + line + "\" should match pattern: \"" + pattern.toString() + "\"");
    }

    private void assertIntInOrder(final List<Integer> nums, final int idx) {
        assertTrue(nums.get(idx - 1) < nums.get(idx),
                "in list: " + nums + " [" + idx + "]=" + nums.get(idx) + " should be bigger than [" + (idx - 1)
                        + "]=" + nums.get(idx - 1));
    }

    private boolean notInSameOrder(final List<String> idOrder, final List<String> mwOrder) {
        boolean differentIndexFound = false;
        for (int i = 0; i < mwOrder.size() && !differentIndexFound; ++i) {
            final int idx = mwOrder.indexOf(idOrder.get(i));
            differentIndexFound = idx != i;
        }
        return differentIndexFound;
    }
}
