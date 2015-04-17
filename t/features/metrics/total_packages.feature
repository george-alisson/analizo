Feature: total number of packages
  As a software developer
  I want analizo to report the number of packages in my code
  So that I can evaluate it

  Scenario: "Multi Dir" project
    Given I am in t/samples/multidir/<language>
    When I run "analizo metrics ."
    Then analizo must report that the project has total_packages = <value>
    Examples:
      | language | value |
      | cpp      |   2   |
      | java     |   3   |

