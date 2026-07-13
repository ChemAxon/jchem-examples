package search.hitdisplay;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatCode;

class PartialCleanExampleTest {

    @Test
    void canRun() {
        assertThatCode(() -> PartialCleanExample.main(new String[]{"hideDisplay"})).doesNotThrowAnyException();
    }
}
