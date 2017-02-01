Feature: category

  Scenario: category methods
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.category_template = "category_template.html"
	akcms.layout = false
      end
      
      """
    And a file named "source/game/wot.html.erb" with "category: <%= current_page.category %>"
    And a file named "source/category_template.html.erb" with ""
    And the Server is running at "basic-app"

    When I go to "/game/wot.html"
    Then the status code should be "200"
    Then I should see "category: game"

  ################################################################
  Scenario: category template
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.category_template = "category_template.html"
      end
      """
    And a file named "source/game/wot.html.md" with:
      """
      ---
      layout: layout
      ---
      playing wot now.
      """

    And a file named "source/category_template.html.erb" with:
      """
      categories: <%= akcms.categories.map {|category, res| res.locals[:display_name]}.join(",") %>
      """
    And the Server is running at "basic-app"

    When I go to "/game.html"
    Then the status code should be "200"
    Then I should see "categories: game"

  ################################################################
  Scenario: category display name
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.category_template = "category_template.html"
      end
      """
    And a file named "source/game/wot.html.md" with:
      """
      ---
      layout: layout
      ---
      playing wot now.
      """

    And a file named "source/game/category_name.txt" with "GAMEGAMEGAME"
    And a file named "source/category_template.html.erb" with:
      """
      categories: <%= akcms.categories.map {|category, res| res.locals[:display_name]}.join(",") %>
      """
    And the Server is running at "basic-app"

    When I go to "/game.html"
    Then the status code should be "200"
    Then I should see "categories: GAMEGAMEGAME"


    



