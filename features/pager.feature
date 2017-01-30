Feature: pager

  Scenario: pager
    Given a fixture app "empty-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.layout = false
      end
      
      """
    And a file named "source/a.html.erb" with:
      """
      ---
      title: AAA
      date: 2017/1/1
      ---
      prev: <%= current_resource.prev_article.try(:title) || "NO PREV" %>
      next: <%= current_resource.next_article.try(:title) || "NO NEXT" %>
      """
    And a file named "source/b.html.erb" with:
      """
      ---
      title: BBB
      date: 2017/1/2
      ---
      prev: <%= current_resource.prev_article.try(:title) || "NO PREV" %>
      next: <%= current_resource.next_article.try(:title) || "NO NEXT" %>
      """

    And the Server is running at "empty-app"

    When I go to "/a.html"
    Then the status code should be "200"
    And I should see "prev: NO PREV"
    And I should see "next: BBB"

    When I go to "/b.html"
    Then the status code should be "200"
    And I should see "prev: AAA"
    And I should see "next: NO NEXT"
    





