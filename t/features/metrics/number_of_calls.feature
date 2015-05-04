Feature: number of calls
  As a software developer
  I want analizo to report the number of calls of each module
  So that I can evaluate it

  Scenario: number of methods of the polygon cpp sample
    Given I am in t/samples/polygons/cpp
    When I run "analizo metrics ."
    Then analizo must report that module <module> has calls = <calls>
    Examples:
      | module  | calls |
      | Polygon |  2    |

