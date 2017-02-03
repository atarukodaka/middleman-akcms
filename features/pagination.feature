Feature: pagination

  Scenario: pagination
    Given a fixture app "basic-app"
    And a file named "source/index.html.erb" with:
      """
      ---
      title: home
      date: 2016/12/31
      pagination:
        per_page: 2
      ---
      <% page_articles.each {|article| %>
        - title: <%= article.title %>
      <% } %>
      <%= paginator.page_number %> / <%= paginator.num_pages %>
      <%if paginator.prev_page %>
        prev: <%= paginator.prev_page.path %>
      <% end %>
      <%if paginator.next_page %>
        next: <%= paginator.next_page.path %>
      <% end %>
      """

    And a file named "source/1.html.md" with:
      """
      ---
      title: 1
      date: 2017/1/1
      ---
      """
    And a file named "source/2.html.md" with:
      """
      ---
      title: 2
      date: 2017/1/2
      ---
      """
    And a file named "source/3.html.md" with:
      """
      ---
      title: 3
      date: 2017/1/3
      ---
      """
    And the Server is running at "basic-app"

    When I go to "/index.html"
    Then the status code should be "200"
    And I should see "1 / 2"
    And I should see "- title: 3"
    And I should see "- title: 2"    
    And I should not see "- title: 1"    
    And I should see "next: index-page-2.html"
    And I should not see "prev:"

    When I go to "/index-page-2.html"
    Then the status code should be "200"
    And I should see "2 / 2"
    And I should see "- title: 1"
    And I should see "- title: home"    
    And I should not see "- title: 2"    
    And I should not see "- title: 3"    
    And I should not see "next:"
    And I should see "prev: index.html"


  Scenario: pagination: use render
    Given a fixture app "basic-app"
    And a file named "source/index.html.erb" with:
      """
      ---
      title: home
      date: 2016/12/31
      pagination:
        per_page: 2
      ---
      <% page_articles.each {|article| %>
        - title: <%= article.title %>
      <% } %>
      <%= pagination_render(:prev_page, label: "&laquo;") %>
      <%= pagination_render(:pages, max_display: 8) %>
      <%= pagination_render(:next_page, label: "&raquo;") %>
      """

    And a file named "source/1.html.md" with:
      """
      ---
      title: 1
      date: 2017/1/1
      ---
      """
    And a file named "source/2.html.md" with:
      """
      ---
      title: 2
      date: 2017/1/2
      ---
      """
    And a file named "source/3.html.md" with:
      """
      ---
      title: 3
      date: 2017/1/3
      ---
      """
    And the Server is running at "basic-app"

    When I go to "/index.html"
    Then the status code should be "200"
    And I should see "&raquo;"
    And I should see "index-page-2"

    