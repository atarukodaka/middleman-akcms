Feature: ancestors

  Scenario: ancestors
    Given a fixture app "basic-app"
    And a file named "source/game/kancolle/event/2015-summer.html.erb" with:
      """
      ---
      ---
      <% current_resource.metadata[:ancestors].each_with_index do |res, i| %>
      <%= i %>: <%= res.path %>
      <% end %>
      """

    And the Server is running at "basic-app"

    When I go to "/game/kancolle/event/2015-summer.html"
    Then the status code should be "200"
    And I should see "0: game/kancolle/event/index.html"
    And I should see "1: game/kancolle/index.html"
    And I should see "2: game/index.html"
    And I should see "3: index.html"