package search.db;

import java.util.List;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class RetrievingDatabaseFieldsExampleTest {

    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        RetrievingDatabaseFieldsExample.out = pc.getOutStream();
    }

    @Test
    void searchRetrievesFields() {
        RetrievingDatabaseFieldsExample.main(null);
        final List<String> lines = pc.getOutputLines();
        final int idIdx = lines.indexOf("ID: 6");
        assertThat(lines.subList(idIdx, idIdx + 3))
                .as("ID, Formula, and Mass should appear consecutively")
                .satisfiesExactly(
                        line -> assertThat(line).isEqualTo("ID: 6"),
                        line -> assertThat(line).isEqualTo("Formula: C20H10Br2O5"),
                        line -> assertThat(line).startsWith("Mass: ")
                );
        assertThat(lines.stream().filter("ID: 6"::equals).count())
                .as("ID: 6 should be found twice").isEqualTo(2);
        assertThat(lines.stream().filter("Formula: C20H10Br2O5"::equals).count())
                .as("C20H10Br2O5 formula should be found twice").isEqualTo(2);
        assertThat(lines.stream().filter(line -> line.startsWith("Mass: ")).count())
                .as("Mass should be found eight times").isEqualTo(8);
    }

    @AfterEach
    void resetOutputStream() {
        RetrievingDatabaseFieldsExample.out = System.out;
    }

}
