package search;

import static org.junit.Assert.assertThat;
import static org.hamcrest.Matchers.*;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class DuplicateSearchExampleTest {

	private static final Pattern isDuplicateMatcher = Pattern.compile("(\\d+)( is duplicate of )(\\d+)");

	private ByteArrayOutputStream outBaos = new ByteArrayOutputStream();
	private ByteArrayOutputStream errorBaos = new ByteArrayOutputStream();
	private PrintStream outMock = new PrintStream(outBaos);
	private PrintStream errorMock = new PrintStream(errorBaos);

	@Before
	public void setPrintStreams() {
		DuplicateSearchExample.out = outMock;
		DuplicateSearchExample.err = errorMock;
	}

	@Test
	public void testMatches() throws Exception {
		DuplicateSearchExample.main(new String[] {});
		List<String> lines = getLines(outBaos);
		List<IdPair> idPairs = lines.stream().map(String::trim).filter(s -> isDuplicateMatcher.matcher(s).matches())
				.map(this::convertLine).collect(Collectors.toList());
		assertThat("we expect 6 matches", idPairs, hasSize(6));
		assertThat("All predefined pairs shuld be found", idPairs, hasItems(new IdPair(669, 665), new IdPair(792, 197),
				new IdPair(958, 815), new IdPair(669, 665), new IdPair(792, 197), new IdPair(958, 815)));
		assertThat("we don't expect any errors", getLines(errorBaos), hasSize(0));
	}

	private List<String> getLines(ByteArrayOutputStream baos) throws IOException {
		List<String> lines = new ArrayList<>();
		try (BufferedReader br = new BufferedReader(
				new InputStreamReader(new ByteArrayInputStream(baos.toByteArray())))) {
			String line = null;
			while ((line = br.readLine()) != null) {
				lines.add(line);
			}
		}
		return lines;
	}

	private IdPair convertLine(String line) {
		Matcher matcher = isDuplicateMatcher.matcher(line);
		if (!matcher.matches()) {
			throw new IllegalStateException("Can not work with: " + line);
		}
		int id1 = Integer.parseInt(matcher.group(1));
		int id2 = Integer.parseInt(matcher.group(3));
		return new IdPair(id1, id2);
	}

	@After
	public void resetPrintStreams() {
		DuplicateSearchExample.out = System.out;
		DuplicateSearchExample.err = System.err;
	}

	private static class IdPair {
		private final int first;
		private final int second;

		public IdPair(int first, int second) {
			this.first = first;
			this.second = second;
		}

		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + first;
			result = prime * result + second;
			return result;
		}

		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			IdPair other = (IdPair) obj;
			if (first != other.first)
				return false;
			if (second != other.second)
				return false;
			return true;
		}

		@Override
		public String toString() {
			return "IdPair [first=" + first + ", second=" + second + "]";
		}

	}

}
