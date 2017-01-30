Feature: layout

  Scenario: layout
    Given a fixture app "basic-app"
    And a file named "source/title.html.md" with:
      """
      ---
      title: cooking
      layout: page
      ---
      according to the title
      """

    And a file named "source/layouts/page.erb" with:
      """
      title: <%= current_page.title %>

      <%= yield %>
      """

    And the Server is running at "basic-app"

    When I go to "/title.html"
    Then the status code should be "200"
    And I should see "according to the title"
    And I should see "title: cooking"


    



