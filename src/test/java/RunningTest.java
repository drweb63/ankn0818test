import cucumber.api.CucumberOptions;
import cucumber.api.SnippetType;
import cucumber.api.junit.Cucumber;
import org.junit.runner.RunWith;

@RunWith(Cucumber.class)
@CucumberOptions(
        features = "src/test/java/ankn0818/features",
        glue = "ankn0818",
        tags = "@test#1",
        snippets = SnippetType.CAMELCASE
)
public class RunningTest {
}