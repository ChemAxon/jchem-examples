package search;

import com.chemaxon.test.helper.PrintCollector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

class DuplicateSearchExampleTest {

    private static final Pattern isDuplicateMatcher = Pattern.compile("(\\d+)( is duplicate of )(\\d+)");

    private final PrintCollector printCollector = new PrintCollector();

    @BeforeEach
    void setPrintStreams() {
        DuplicateSearchExample.out = printCollector.getOutStream();
        DuplicateSearchExample.err = printCollector.getErrorStream();
    }

    @Test
    void testMatches() throws Exception {
        DuplicateSearchExample.main(new String[]{});
        final List<String> lines = printCollector.getOutputLines();
        final List<IdPair> idPairs = lines.stream().map(String::trim).filter(s -> isDuplicateMatcher.matcher(s).matches())
                .map(this::convertLine).collect(Collectors.toList());
        assertThat(idPairs).as("we expect 6 matches").hasSize(6);
        assertThat(idPairs).as("All predefined pairs shuld be found")
                .contains(new IdPair(669, 665), new IdPair(792, 197),
                        new IdPair(958, 815), new IdPair(669, 665),
                        new IdPair(792, 197), new IdPair(958, 815));
        assertThat(printCollector.getErrorLines()).as("we don't expect any errors").isEmpty();
    }

    private IdPair convertLine(final String line) {
        final Matcher matcher = isDuplicateMatcher.matcher(line);
        if (!matcher.matches()) {
            throw new IllegalStateException("Can not work with: " + line);
        }
        final int id1 = Integer.parseInt(matcher.group(1));
        final int id2 = Integer.parseInt(matcher.group(3));
        return new IdPair(id1, id2);
    }

    @AfterEach
    void resetPrintStreams() {
        DuplicateSearchExample.out = System.out;
        DuplicateSearchExample.err = System.err;
    }

    private record IdPair(int first, int second) {

        @Override
            public boolean equals(final Object obj) {
                if (this == obj)
                    return true;
                if (obj == null)
                    return false;
                if (getClass() != obj.getClass())
                    return false;
                final IdPair other = (IdPair) obj;
                if (first != other.first)
                    return false;
                return second == other.second;
            }

            @Override
            public String toString() {
                return "IdPair [first=" + first + ", second=" + second + "]";
            }

        }

}
