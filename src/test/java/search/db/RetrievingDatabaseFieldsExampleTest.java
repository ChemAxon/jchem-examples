package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class RetrievingDatabaseFieldsExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    public void changeOutputStream() {
        RetrievingDatabaseFieldsExample.out = pc.getOutStream();
    }

    @Test
    public void searchRetrievsFields() {
        RetrievingDatabaseFieldsExample.main(null);
        final List<String> lines = pc.getOutputLines();
        // JUnit 5: condition first, message last
        assertTrue(followsEachOther(lines, "ID: 6", "Formula: C20H10Br2O5", "Mass: 490.103"), "These messages should follow each other");
        assertEquals(2, count(lines, "ID: 6"), "These should be found twice");
        assertEquals(2, count(lines, "Formula: C20H10Br2O5"), "These should be found twice");
        assertEquals(2, count(lines, "Mass: 490.103"), "These should be found twice");
    }

    @AfterEach
    public void resetOutputStream() {
        RetrievingDatabaseFieldsExample.out = System.out;
    }

    private int count(final List<String> lines, final String string) {
        int count = 0;
        for (final String l : lines) {
            if (l.equals(string)) {
                ++count;
            }
        }
        return count;
    }

    private boolean followsEachOther(final List<String> lines, final String... strs) {
        int previous = lines.indexOf(strs[0]);
        for (int i = 1; i < strs.length; ++i) {
            final int idx = lines.indexOf(strs[i]);
            if (idx < 1 || idx != previous + 1) {
                return false;
            }
            previous = idx;
        }
        return previous > 0;
    }

}
