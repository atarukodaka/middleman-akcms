Feature: directory summary

  Scenario: dir
    Given a fixture app "directory-summary-app"
    And a file named "source/game/kancolle/event/2015-summer.html.erb" with:
      """
      ---
      title: event2015sum
      layout: layout
      ---
      directory name: <%= current_resource.directory.name %>
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

  Scenario: sitemap index resource
    Given a fixture app "basic-app"
    And a file named "source/foo/index.html.erb" with ""
    And a file named "source/show.html.erb" with:
      """
      path: <%= sitemap.find_directory_index("foo").path %>
      """
    And the Server is running at "basic-app"
    When I go to "/show.html"
    Then the status code should be "200"
    And I should see "path: foo/index.html"

  Scenario: index resource
    Given a fixture app "basic-app"
    And a file named "source/index.html.erb" with ""
    And a file named "source/foo/index.html.erb" with ""
    And a file named "source/show.html.erb" with:
      """
      /: <%= sitemap.find_directory_index("/").path %>
      /foo: <%= sitemap.find_directory_index("/foo").path %>
      """
    And the Server is running at "basic-app"
    When I go to "/show.html"
    Then the status code should be "200"
    And I should see "/: index.html"
    And I should see "/foo: foo/index.html"

  Scenario: children, index methods for directory
    Given a fixture app "directory-summary-app"
    And a file named "source/foo/index.html.erb" with:
      """
      children: <%= current_resource.children.select(&:directory_index?).map(&:path).join(",") %>
      """
    And a file named "source/foo/bar.html.erb" with:   
      """
      index: <%= current_resource.directory.index.path %>
      """
    And a file named "source/foo/baz/index.html.erb" with ""
    And the Server is running at "directory-summary-app"
    When I go to "/foo/index.html"
    Then the status code should be "200"
    And I should see "children: foo/baz/index.html"
    When I go to "/foo/bar.html"
    Then the status code should be "200"
    And I should see "index: foo/index.html"

  Scenario: eponymous path
    Given a fixture app "directory-summary-app"
    And a file named "source/foo/bar.html" with ""
    And a file named "source/foo/bar/baz.html.erb" with:
      """
      parent: <%= current_resource.parent.path %>
      """
    
    And the Server is running at "directory-summary-app"

    When I go to "/foo/bar/index.html"
    Then the status code should be "404"

    When I go to "/foo/bar/baz.html"
    Then the status code should be "200"
    And I should see "parent: foo/bar.html"