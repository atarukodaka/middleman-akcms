Feature: layout

  Scenario: layout
    Given a fixture app "basic-app"
    And a file named "source/page_layout.html.md" with:
      """
      ---
      layout: page
      ---
      using page layout.
      """

    And a file named "source/layouts/page.erb" with:
      """
      page layout:
      <%= yield %>
      """

    And the Server is running at "basic-app"

    When I go to "/page_layout.html"
    Then the status code should be "200"
    And I should see "using page layout."
    And I should see "page layout:"


    



