Feature: article methods

  Scenario: title methods
    Given a fixture app "basic-app"
    And a file named "source/foo.html.erb" with:
      """
      ---
      title: FOO!!!
      ---
      title: <%= current_resource.title %>
      """
      
    And the Server is running at "basic-app"
    When I go to "/foo.html"
    Then the status code should be "200"
    And I should see "title: FOO!!!"


  Scenario: date methods
    Given a fixture app "basic-app"
    And a file named "source/with_date.html.erb" with:
      """
      ---
      date: 2017/1/1
      ---
      date: <%= current_resource.date.strftime("%Y/%m/%d") %>
      """
    And a file named "source/no_date.html.erb" with:
      """
      ---
      ---
      date: <%= current_resource.date.strftime("%Y/%m/%d") %>
      """
    
    And the Server is running at "basic-app"
    When I go to "/with_date.html"
    Then the status code should be "200"
    And I should see "date: 2017/01/01"

    When I go to "/no_date.html"
    Then the status code should be "200"
    And I should not see "date: 2017/01/01"

  Scenario: copyright 2010-2017
    Given a fixture app "basic-app"
    And a file named "source/first.html.md" with:
      """
      ---
      date: 2010/1/1
      ---
      """
    And a file named "source/last.html.md" with:
      """
      ---
      date: 2017/1/1
      ---
      """
    And a file named "source/index.html.erb" with:
      """
      <%= copyright %>
      """
    And the Server is running at "basic-app"
    When I go to "/index.html"
    Then the status code should be "200"
    And I should see "Copyright(2010-2017)"

      Scenario: copyright 2010-2010
    Given a fixture app "basic-app"
    And a file named "source/first.html.md" with:
      """
      ---
      date: 2010/1/1
      ---
      """
    And a file named "source/last.html.md" with:
      """
      ---
      date: 2010/1/2
      ---
      """
    And a file named "source/index.html.erb" with:
      """
      ---
      date: 2010/1/3
      ---
      <%= copyright %>
      """
    And the Server is running at "basic-app"
    When I go to "/index.html"
    Then the status code should be "200"
    And I should see "Copyright(2010)"

    