Feature: directory summary

  Scenario: dir
    Given a fixture app "basic-app"
    And a file named "source/game/kancolle/event/2015-summer.html.md" with:
    #And a file named "source/game/kancolle/event.html.md" with:
      """
      ---
      title: event2015sum
      layout: layout
      ---
      event
      """

    And the Server is running at "basic-app"

    When I go to "/game/kancolle/event/index.html"
    Then the status code should be "200"

    When I go to "/game/kancolle/index.html"
    Then the status code should be "200"

    When I go to "/game/index.html"
    Then the status code should be "200"


    


