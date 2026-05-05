package search.db;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import com.chemaxon.test.helper.PrintCollector;

import static org.assertj.core.api.Assertions.assertThat;

class SimilaritySearchExampleTest {
    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        SimilaritySearchExample.out = pc.getOutStream();
    }

    @Test
    void chemicalHashedFingerprintReturnsWithResults() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(1)).isEqualTo("Results using chemical hashed fingerprint:");
        assertThat(pc.getOutputLines().get(2)).startsWith("Hit count: ");
    }

    @Test
    void pharmacophoreReturnsWithResults() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(5)).isEqualTo("Results using descriptor: Pharmacophore");
        assertThat(pc.getOutputLines().get(6)).startsWith("Hit count: ");
    }

    @Test
    void hDonorReturnsWithResults() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(9)).isEqualTo("Results using descriptor: HDonor");
        assertThat(pc.getOutputLines().get(10)).startsWith("Hit count: ");
    }

    @Test
    void hAcceptorReturnsWithResults() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(13)).isEqualTo("Results using descriptor: HAcceptor");
        assertThat(pc.getOutputLines().get(14)).startsWith("Hit count: ");
    }

    @AfterEach
    void resetOutputStream() {
        SimilaritySearchExample.out = System.out;
    }
}
