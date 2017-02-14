Feature: pagination

  Scenario: pagination
    Given a fixture app "empty-app"
    And a file named "config.rb" with "activate :akcms"
    And a file named "source/index.html.erb" with:
      """
      ---
      title: home
      date: 2016/12/31
      layout: false
      pagination:
        per_page: 2
      ---
      <% if pagination? %>
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
    And the Server is running at "empty-app"

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


  Scenario: dir summary pagination
    Given a fixture app "directory-summary-app"
    And a file named "source/foo/1.html" with ""
    And a file named "source/foo/2.html" with ""    
    And a file named "source/foo/3.html" with ""
    And a template named "directory_summary_template.html.erb" with:
      """
      ---
      pagination:
        per_page: 1
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
    And the Server is running at "directory-summary-app"
    When I go to "/foo/index.html"
    Then the status code should be "200"
    And I should see "1 / 3"
    And I should see "next: foo/index-page-2.html"
    
  Scenario: pagination: use render
    Given a fixture app "empty-app"
    And a file named "config.rb" with "activate :akcms"
    And a file named "source/index.html.erb" with:
      """
      ---
      title: home
      layout: false
      type: summary
      date: 2016/12/31
      pagination:
        per_page: 1
      ---
      <% paginator[:paginated_resources_for_navigation].call(current_resource, 2).each do |res| %>
        - <%= res.locals[:paginator][:page_number] %>
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
    And the Server is running at "empty-app"

    When I go to "/index.html"
    Then the status code should be "200"

    And I should see "  - 1"
    And I should see "  - 2"
    And I should not see "  - 3"

    When I go to "/index-page-3.html"
    Then the status code should be "200"

    And I should not see "  - 1"
    And I should see "  - 2"
    And I should see "  - 3"


      