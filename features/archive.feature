Feature: archive

  Scenario: archive template
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.archive_year_template = "archive_template.html"
        akcms.archive_month_template = "archive_template.html"
        akcms.archive_day_template = "archive_template.html"
      end
      """
    And a file named "source/foo.html.md" with:
      """
      ---
      title: foo
      date: 2017/2/3
      ---
      foofoo
      """

    And a file named "source/archive_template.html.erb" with:
      """
      <% titles = {year: "Yearly", month: "Monthly", day: "Daily"} %>
      <%= titles[archive_type] %> Archives: <%= date.strftime("%d %b %Y") %>

      <% articles.each {|page| %>
       title: <%= page.title %>
       date: <%= page.date.strftime("%Y-%m-%d") %>
      <% } %>
      
      """
    And a file named "source/archives.html.erb" with:
      """
      <% sitemap.archives[:month].each {|date, res| %>
        date: <%= date.strftime("%Y-%m") %>
        res: <%= res.path %>
      <% } %>
      """

    And the Server is running at "basic-app"

    ## yearly
    When I go to "/archives/2017.html"
    Then the status code should be "200"
    And I should see "Yearly"
    And I should see "date: 2017-02-03"

    ## monthly
    When I go to "/archives/2017-02.html"
    Then the status code should be "200"
    And I should see "Monthly"
    And I should see "date: 2017-02-03"

    ## daily
    When I go to "/archives/2017-02-03.html"
    Then the status code should be "200"
    And I should see "Daily"
    And I should see "date: 2017-02-03"

    When I go to "/archives.html"
    Then the status code should be "200"
    And I should see "date: 2017-02"
    And I should see "res: archives/2017-02.html"

