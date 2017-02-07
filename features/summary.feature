Feature: summary

  Scenario: summary length
    Given a fixture app "basic-app"
    And a file named "source/index.html.md" with:
      """
      ---
      ---
      1234567890abcdefg
      """

    And a file named "source/summary.html.erb" with:
      """
      <%= akcms.summary(top_page, 10) %>
      """

    And the Server is running at "basic-app"

    When I go to "/summary.html"
    Then the status code should be "200"
    And I should see "1234567890"
    And I should not see "a"
