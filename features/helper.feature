Feature: helpers

  Scenario: helper
    Given a fixture app "basic-app"
    And a file named "source/index.html.erb" with:
      """
      ---
      title: HOME
      ---
      """
      
    And a file named "source/helpers.html.erb" with:
      """
      ---
      layout: false
      ---
      akcms: <%= akcms.class %>
      page_for: <%= page_for("/helpers.html").path %>
      top_page: <%= top_page.data.title %>
      """

    And the Server is running at "basic-app"

    When I go to "/index.html"
    Then the status code should be "200"

    When I go to "/helpers.html"    
    And I should see "akcms: Middleman::Akcms::Controller"
    And I should see "page_for: helpers.html"
    And I should see "top_page: HOME"
    


