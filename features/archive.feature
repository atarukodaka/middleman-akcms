Feature: archive

  Scenario: archive template
    Given a fixture app "basic-app"
    And a file named "config.rb" with:
      """
      activate :akcms do |akcms|
        akcms.archive_template = "archive_template.html"
      end
      """
    And a file named "source/foo.html.md" with:
      """
      ---
      title: foo
      date: 2017/1/1
      ---
      foofoo
      """

    And a file named "source/archive_template.html.erb" with:
      """
      monthly archives: <%= date.strftime("%b %Y") %>

      <% articles.each {|page| %>
       title: <%= page.title %>
       date: <%= page.date.strftime("%Y-%m-%d") %>
      <% } %>
      
      """
    And a file named "source/archives.html.erb" with:
      """
      <% akcms.archives.each {|month, articles| %>
        - <%= month.strftime("%Y-%m") %>
      <% } %>

      <% akcms.archive_resources.each {|month, res| %>
        res: <%= res.path %>
      <% } %>
      """

    And the Server is running at "basic-app"

    When I go to "/archives/2017-01.html"
    Then the status code should be "200"
    And I should see "title: foo"
    And I should see "date: 2017-01-01"

    When I go to "/archives.html"
    Then the status code should be "200"
    And I should see "- 2017-01"
    And I should see "- 2017-02"
    And I should see "res: archives/2017-01.html"
    And I should see "res: archives/2017-02.html"

