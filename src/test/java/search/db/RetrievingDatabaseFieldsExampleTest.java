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
        assertThat(lines.stream().filter("ID: 6"::equals).count())
                .as("ID: 6 should be found twice").isEqualTo(2);
        assertThat(lines.stream().filter("Formula: C20H10Br2O5"::equals).count())
                .as("Formula should be found twice").isEqualTo(2);
        assertThat(lines.stream().filter(line -> line.startsWith("Mass: ")).count())
                .as("Mass should be found twice").isEqualTo(8);
    }

    @AfterEach
    void resetOutputStream() {
        RetrievingDatabaseFieldsExample.out = System.out;
    }

}
