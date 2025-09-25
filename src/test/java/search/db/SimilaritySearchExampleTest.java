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
	public void chemicalHashedFingerprintHas10Hits() {
		SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(1), Matchers.is("Results using chemical hashed fingerprint:"));
        assertThat(pc.getOutputLines().get(2), Matchers.is("Hit count: 10"));
    }

    @Test
    public void pharmacophoreHas130Hits() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(5), Matchers.is("Results using descriptor: Pharmacophore"));
        assertThat(pc.getOutputLines().get(6), Matchers.is("Hit count: 130"));
    }

    @Test
    public void hDonorHas382Hits() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(9), Matchers.is("Results using descriptor: HDonor"));
        assertThat(pc.getOutputLines().get(10), Matchers.is("Hit count: 382"));
    }

    @Test
    public void hAcceptorHas382Hits() {
        SimilaritySearchExample.main(null);
        assertThat(pc.getOutputLines().get(13), Matchers.is("Results using descriptor: HAcceptor"));
        assertThat(pc.getOutputLines().get(14), Matchers.is("Hit count: 382"));
    }

    @After
	public void resetOutputStream() {
		SimilaritySearchExample.out=System.out;
	}
}
