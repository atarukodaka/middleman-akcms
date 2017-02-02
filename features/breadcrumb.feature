Feature: breadcrumb

  Scenario: breadcrumb
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.category_template = "category_template.html"
	akcms.layout = false
      end
      """
    And a file named "source/game/wows.html" with "wows"
    And a file named "source/game/wot/tanks.html.erb" with "<%= breadcrumb(current_resource) %>"

    And a file named "source/category_template.html.erb" with ""
    And the Server is running at "basic-app"

    When I go to "/game/wot/tanks.html"
    Then the status code should be "200"
    And I should see "<nav class="
    And I should see "Home"
    And I should see "/game/"
    And I should see "/game/wot/"
