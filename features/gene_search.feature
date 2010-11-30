@no-txn
Feature: Gene Search
  In order to answer a question
  As a user
  I want to be able to setup a search

  Background:
    Given the following ontology terms exist:
      | uri | css_klass | name |
      | http://purl.org/obo/owl/MA#MA_0000062 | mouse-anatomy | aorta |
      | http://purl.org/obo/owl/CL#CL_0000000 | cell | cell |

    Given the following qtls exist:
      | symbol |
      | Bp101 |
      | Bp103 |
      | Rf1 |

  Scenario: Visit the search page
    Given I am on the home page
    When I go to the new gene search page
    Then I should see "New gene search" within ".page-title"

  @selenium
  Scenario Outline: Select an ontology term
    Given I am on the new gene search page
    When I fill in "ontologyterm-search" with "<typed_string>"
    And I wait for 2 seconds
    And I click on the "<name>" autocomplete option
    Then I should see "<name>" within ".selected-term"
    Examples:
      | typed_string | name |
      | aor | aorta |
      | ce | cell |

  @selenium
  Scenario Outline: Select an qtl
    Given I am on the new gene search page
    And I fill in "qtl-search" with "<typed_string>"
    And I wait for 2 seconds
    And I click on the "<qtl>" autocomplete option
    Then I should see "<term>" within ".selected-term"
    And the "qtl-symbol" field should contain "<qtl>"
    And the "qtl-chromosome-name" field should contain "<chromosome>"
    And the "qtl-starts-at" field should contain "<starts_at>"
    And the "qtl-ends-at" field should contain "<ends_at>"
    Examples:
      | typed_string | qtl | term | chromosome | starts_at | ends_at |
      | bp | Bp101 | increased blood pressure | 2 | 155920808 | 210636008 |
      | rf | Rf1 | glomerulosclerosis | 1 | 202322277 | 247322277 |

  @selenium
  Scenario Outline: Select an direct range
    Given I am on the new gene search page
    When I am pending
    When I follow "Direct" within "#tabs"
    And I fill in "chromosome" with "<chromosome>"
    And I fill in "starts_at" with "<starts_at>"
    And I fill in "ends_at" with "<ends_at>"
    And I press "Submit search"
    Then I should see "<gene>" within ".selected-genes"
    And I should see "<chromosome>" within ".qtl-chromosome-name"
    And I should see "<starts_at>" within ".qtl-starts-at"
    And I should see "<ends_at>" within ".qtl-ends-at"
    Examples:
      | chromosome | starts_at | ends_at | gene |
      | 1 | 16332801 | 16454055 | Ahi1 |
      | 2 | 19821482 | 19822544 | Ak1 |

  @selenium
  Scenario: Upload a gene file
    Given I am on the new gene search page
    When I am pending
    And I follow "File Upload" within "#tabs"
    And I upload "metadata/genes.txt"
    Then I should see "gene1" within ".selected-genes"

  @selenium
  Scenario: Submit a search
    Given I am on the new gene search page
    And I fill in "qtl-search" with "Bp10"
    And I wait for 2 seconds
    And I click on the "Bp103" autocomplete option
    And I should see "increased blood pressure" within ".selected-term"
    And I fill in "ontologyterm-search" with "ce"
    And I wait for 2 seconds
    And I click on the "cell" autocomplete option
    And I should see "cell" within ".selected-term"
    When I press "Submit search"
    And I wait for 5 seconds
    Then I should see "Results"
    And I should see "Guca2b" within ".selected-gene"
