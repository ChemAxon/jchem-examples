package search.db;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SimilaritySearchExampleTest {
    private final PrintCollector pc = new PrintCollector();

    @BeforeEach
    void changeOutputStream() {
        SimilaritySearchExample.out = pc.getOutStream();
    }

    @Test
    void chemicalHashedFingerprintHas10Hits() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(1).equals("Results using chemical hashed fingerprint:"));
        assertThat(pc.getOutputLines().get(2).equals("Hit count: 10"));
    }

    @Test
    void pharmacophoreHas130Hits() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(5).equals("Results using descriptor: Pharmacophore"));
        assertThat(pc.getOutputLines().get(6).equals("Hit count: 130"));
    }

    @Test
    void hDonorHas382Hits() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(9).equals("Results using descriptor: HDonor"));
        assertThat(pc.getOutputLines().get(10).equals("Hit count: 382"));
    }

    @Test
    void hAcceptorHas382Hits() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(13).equals("Results using descriptor: HAcceptor"));
        assertThat(pc.getOutputLines().get(14).equals("Hit count: 382"));
    }

    @AfterEach
    void resetOutputStream() {
        SimilaritySearchExample.out = System.out;
    }
}
