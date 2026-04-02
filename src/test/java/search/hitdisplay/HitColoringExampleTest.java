package search.hitdisplay;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatCode;

class HitColoringExampleTest {

    @Test
    void canRun() {
        assertThatCode(() -> HitColoringExample.main(new String[]{"hideDisplay"})).doesNotThrowAnyException();
    }

}
