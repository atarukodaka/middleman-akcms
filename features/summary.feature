Feature: summary

  Scenario: summary length
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |conf|
        conf.summarizer = Middleman::Akcms::SimpleSummarizer
      end
      """
    And a file named "source/foo.html" with:
      """
      ---
      ---
      1234567890abcdefg
      """

    And a file named "source/summary.html.erb" with:
      """
      <% res = sitemap.find_resource_by_path("/foo.html") %>
      <%= res.summary(10) %>
      """

    And the Server is running at "basic-app"

    When I go to "/summary.html"
    Then the status code should be "200"
    And I should see "1234567890"
    And I should not see "a"

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
      <% res = sitemap.find_resource_by_path("/index.html") %>
      <%= res.summary(10) %>
      """

    And the Server is running at "basic-app"

    When I go to "/summary.html"
    Then the status code should be "200"
    And I should see "1234567890"
    And I should not see "a"
