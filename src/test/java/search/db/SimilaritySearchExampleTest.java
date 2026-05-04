package search.db;

import static org.junit.Assert.assertThat;

import org.hamcrest.Matchers;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.chemaxon.test.helper.PrintCollector;

public class SimilaritySearchExampleTest {
	private PrintCollector pc = new PrintCollector();

	@Before
	public void changeOutputStream() {
		SimilaritySearchExample.out=pc.getOutStream();
	}

	@Test
	public void chemicalHashedFingerprintReturnsWithResults() {
		SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(1), Matchers.is("Results using chemical hashed fingerprint:"));
        assertThat(pc.getOutputLines().get(2), Matchers.startsWith("Hit count: "));
    }

    @Test
    public void pharmacophoreReturnsWithResults() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(5), Matchers.is("Results using descriptor: Pharmacophore"));
        assertThat(pc.getOutputLines().get(6), Matchers.startsWith("Hit count: "));
    }

    @Test
    public void hDonorReturnsWithResults() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(9), Matchers.is("Results using descriptor: HDonor"));
        assertThat(pc.getOutputLines().get(10), Matchers.startsWith("Hit count: "));
    }

    @Test
    public void hAcceptorReturnsWithResults() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(13), Matchers.is("Results using descriptor: HAcceptor"));
        assertThat(pc.getOutputLines().get(14), Matchers.startsWith("Hit count: "));
    }

    @After
	public void resetOutputStream() {
		SimilaritySearchExample.out=System.out;
	}
}
