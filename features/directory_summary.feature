Feature: directory summary

  Scenario: dir
    Given a fixture app "directory-summary-app"
    And a file named "source/game/kancolle/event/2015-summer.html.erb" with:
      """
      ---
      title: event2015sum
      layout: layout
      ---
      directory name: <%= current_resource.metadata[:directory][:name] %>
      """

    And a file named "source/game/kancolle/event/config.yml" with:
      """
      directory_name: EVENT
      """
    And the Server is running at "directory-summary-app"

    When I go to "/game/kancolle/event/2015-summer.html"
    Then the status code should be "200"
    And I should see "directory name: EVENT"
#    And I should see "directory name: event"

    When I go to "/game/kancolle/event/index.html"
    Then the status code should be "200"

    When I go to "/game/kancolle/index.html"
    Then the status code should be "200"

    When I go to "/game/index.html"
    Then the status code should be "200"

  Scenario: enopynous directory index
    Given a fixture app "basic-app"
    And a file named "source/foo/bar/baz/index.html.erb" with:
      """
      parent: <%= current_resource.parent.path %>
      """
    And a file named "source/foo/bar.html" with ""

    And the Server is running at "basic-app"
    When I go to "/foo/bar/baz/index.html"
    Then the status code should be "200"
    And I should see "parent: foo/bar.html"
    


