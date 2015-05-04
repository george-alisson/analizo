Feature: fan out
  As a software developer
  I want analizo to report the fan out of each module
  So that I can evaluate it

  Scenario: number of methods of the polygon cpp sample
    Given I am in t/samples/polygons/cpp
    When I run "analizo metrics ."
    Then analizo must report that module <module> has fout = <fout>
    Examples:
      | module  | fout |
      | Polygon |  1   |

