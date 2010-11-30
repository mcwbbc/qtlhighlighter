Feature: Pages
  In order to get information
  As a user
  I want view specific pages

  Scenario: Home
    Given I am on the home page
    Then I should see "Welcome to QTL Highlighter"

  Scenario: Help
    Given I am on the home page
    When I go to the help page
    Then I should see "QTL Highlighter Help"

  Scenario: About
    Given I am on the home page
    When I go to the about page
    Then I should see "About the QTL Highlighter"



