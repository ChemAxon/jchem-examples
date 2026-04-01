package search.db;

import chemaxon.jchem.version.JChemVersionInfo;
import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;

class SearchTypesExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        SearchTypesExample.out = pc.getOutStream();
    }

    @Test
    void searchTypesTest() {
        SearchTypesExample.main(null);
        final List<String> lines = pc.getOutputLines();
        //System.out.println(lines);
        assertStartsWith(lines.get(0), "21 hit(s) found");
        final int expectedSimilarityHitCount = JChemVersionInfo.getJChemTableVersion() >= 23050000 ? 7 : 6;
        assertStartsWith(lines.get(1), expectedSimilarityHitCount + " hit(s) found");
        assertStartsWith(lines.get(2), "0 hit(s) found");
    }

    private void assertStartsWith(final String line, final String prefix) {
        // JUnit 5: condition first, message last
        assertTrue(line.startsWith(prefix), line + " should start with " + prefix);
    }

    @AfterEach
    void resetOutputStream() {
        SearchTypesExample.out = System.out;
    }

}
