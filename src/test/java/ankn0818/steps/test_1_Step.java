package ankn0818.steps;

import com.codeborne.selenide.Condition;
import cucumber.api.PendingException;
import cucumber.api.java.en.*;

import static com.codeborne.selenide.Condition.text;
import static com.codeborne.selenide.Selectors.byName;
import static com.codeborne.selenide.Selectors.byText;
import static com.codeborne.selenide.Selectors.byValue;
import static com.codeborne.selenide.Selenide.$;
import static com.codeborne.selenide.Selenide.open;
import static com.codeborne.selenide.Selenide.sleep;

public class test_1_Step {

    @Given("^open www\\.google\\.com$")
    public void openWwwGoogleCom() throws Throwable {
        System.setProperty("selenide.browser", "Chrome");
        open("https://www.google.com");
    }

    @When("^type to search field \"([^\"]*)\" text: \"([^\"]*)\"$")
    public void typeToSearchFieldText(String arg1, String arg2) throws Throwable {
        // Write code here that turns the phrase above into concrete actions
        sleep(1000);
        $(byName(arg1)).sendKeys(arg2);
    }

    @When("^press button with value \"([^\"]*)\"$")
    public void pressButtonWithValue(String arg1) throws Throwable {
        // Write code here that turns the phrase above into concrete actions
        $(byValue(arg1)).waitUntil(Condition.visible, 15000).click();
    }

}