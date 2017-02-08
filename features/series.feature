Feature: series

  Scenario: series
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.series_title_template = "%{name} [%{number}]: %{title}"
	akcms.layout = :series
      end
      
      """
    And a file named "source/game/01_install.html.erb" with:
      """
      ---
      title: install
      series: true
      ---
      """
    And a file named "source/game/02_start.html.erb" with:
      """
      ---
      title: start
      series: true
      ---
      """
    And a file named "source/layouts/series.erb" with:
      """
      <% series[:articles].each {|res| %>
        - <%= res.title %>
      <% } %>
      <%= yield %>
      """
    
    And the Server is running at "basic-app"
    When I go to "/game/01_install.html"
    Then the status code should be "200"
    And I should see "game [1]: install"
    And I should see "game [2]: start"    

