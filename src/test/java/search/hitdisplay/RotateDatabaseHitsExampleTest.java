package search.hitdisplay;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThatCode;

class RotateDatabaseHitsExampleTest {

    @Test
    void canRun() {
        assertThatCode(() -> RotateDatabaseHitsExample.main(new String[]{"hideDisplay"})).doesNotThrowAnyException();
    }

}
