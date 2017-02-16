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
      resource_for: <%= resource_for("/helpers.html").path %>
      """

    And the Server is running at "basic-app"

    When I go to "/index.html"
    Then the status code should be "200"

    When I go to "/helpers.html"    
    And I should see "resource_for: helpers.html"
    


