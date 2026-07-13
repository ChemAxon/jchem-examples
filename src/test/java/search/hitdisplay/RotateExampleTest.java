package search.hitdisplay;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatCode;

class RotateExampleTest {

    @Test
    void canRun() {
        assertThatCode(() -> RotateExample.main(new String[]{"hideDisplay"})).doesNotThrowAnyException();
    }
}
