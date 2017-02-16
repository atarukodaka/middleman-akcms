Feature: series

  Scenario: series
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.series_title_template = "%{name} [%{number}]: %{article_title}"
	akcms.layout = :series
      end
      
      """
    And a file named "source/game/config.yml" with:
      """
      series: "PLAY GAME"
      """
    And a file named "source/game/01_install.html.erb" with:
      """
      ---
      title: install
      series: true
      ---
      """
    And a file named "source/game/start.html.erb" with:
      """
      ---
      title: start
      series:
        number: 2
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
    And I should see "PLAY GAME [1]: install"
    And I should see "PLAY GAME [2]: start"    

