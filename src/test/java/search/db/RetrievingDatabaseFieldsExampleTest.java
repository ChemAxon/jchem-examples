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
    void searchRetrievsFields() {
        RetrievingDatabaseFieldsExample.main(null);
        final List<String> lines = pc.getOutputLines();
        assertThat(lines).as("ID, Formula, and Mass should appear consecutively")
                .containsSequence("ID: 6", "Formula: C20H10Br2O5", "Mass: 490.103");
        assertThat(lines.stream().filter("ID: 6"::equals).count())
                .as("ID: 6 should be found twice").isEqualTo(2);
        assertThat(lines.stream().filter("Formula: C20H10Br2O5"::equals).count())
                .as("Formula should be found twice").isEqualTo(2);
        assertThat(lines.stream().filter("Mass: 490.103"::equals).count())
                .as("Mass should be found twice").isEqualTo(2);
    }

    @AfterEach
    void resetOutputStream() {
        RetrievingDatabaseFieldsExample.out = System.out;
    }

}
