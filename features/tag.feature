Feature: tag

  Scenario: tags
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.tag_template = "tag_template.html"
	akcms.tag_link = "tags/%{tag}.html"	
      end
      """
      
    And a file named "source/game/wot.html.md" with:
      """
      ---
      title: wotnoobs
      layout: layout
      tags: fps, noobs
      ---
      playing wot now.
      """

    And a file named "source/tags.html.erb" with:
      """
      <ul>
        <% sitemap.tags.each {|name, res| %>
	  <li><%= link_to(name, res) %></li>
	<% } %>
      </ul>
      """

    And a file named "source/tag_template.html.erb" with:
      """
     tag: <%= tag_name %>
     <% articles.each {|article| %>
      	 - <%= article.title %>
      <% } %>
      """
    
    And the Server is running at "basic-app"

    When I go to "/tags/fps.html"
    Then the status code should be "200"
    And I should see "- wotnoobs"

    When I go to "/tags.html"
    Then the status code should be "200"
    And I should see "fps.html"
    And I should see "noobs.html"
    
    When I go to "/tags/noobs.html"
    Then the status code should be "200"
    And I should see "- wotnoobs"

    

