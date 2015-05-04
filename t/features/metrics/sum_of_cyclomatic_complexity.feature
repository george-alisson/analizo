Feature: sum of cyclomatic complexity
  As a software developer
  I want analizo to report the sum of cyclomatic complexity of each module
  So that I can evaluate it

  Scenario: number of methods of the polygon cpp sample
    Given I am in t/samples/polygons/cpp
    When I run "analizo metrics ."
    Then analizo must report that module <module> has cyclo = <cyclo>
    Examples:
      | module   | cyclo |
      | Polygon  |  1    |
      | CPolygon |  2    |

