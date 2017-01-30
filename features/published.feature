Feature: published

  Scenario: publishability
    Given the Server is running at "basic-app"
    And a file named "source/unpublished.html" with:
      """
      ---
      published: false
      ---
      shouldnt be shown.
      """

    And a file named "source/to_be_published.html" with:
      """
      ---
      published: true
      ---
      ok to show
      """

    And the Server is running at "basic-app"

    When I go to "/unpublished.html"
    Then the status code should be "404"

    When I go to "/to_be_published.html"
    Then I should see "ok to show"


    



