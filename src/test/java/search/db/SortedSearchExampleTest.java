package search.db;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class SortedSearchExampleTest {

    private static final Pattern PATTERN = Pattern.compile("cd_id: (\\d+) dissimilarity: (\\d+\\.\\d+)");
    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        SortedSearchExample.out = pc.getOutStream();
    }

    @Test
    void search() {
        SortedSearchExample.main(null);
        final List<String> lines = pc.getOutputLines();
        assertThat(lines.get(0)).isEqualTo("7 hit(s) found (in ID order)");
        assertThat(lines.get(9)).isEqualTo("7 hit(s) found (in molweight order)");
        final List<String> idOrder = lines.subList(1, 8);
        final List<String> mwOrder = lines.subList(10, lines.size());
        assertThat(idOrder).as("Both orderings should contain the same hits")
                .containsExactlyInAnyOrderElementsOf(mwOrder);
        final List<Integer> ids = idOrder.stream().map(this::extractId).toList();
        assertThat(ids).as("IDs should be in ascending order").isSorted();
        assertThat(idOrder).as("Molweight order should differ from ID order")
                .isNotEqualTo(mwOrder);
    }

    @AfterEach
    void resetOutputStream() {
        SortedSearchExample.out = System.out;
    }

    private int extractId(final String line) {
        final Matcher matcher = PATTERN.matcher(line);
        if (matcher.matches()) {
            return Integer.parseInt(matcher.group(1));
        }
        throw new IllegalStateException("Line does not match expected pattern: \"" + line + "\"");
    }
}
