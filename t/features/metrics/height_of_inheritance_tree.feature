Feature: height of inheritance tree
  As a software developer
  I want analizo to report the height of inheritance tree of each module
  So that I can evaluate it

  Scenario: number of methods of the polygon cpp sample
    Given I am in t/samples/polygons/cpp
    When I run "analizo metrics ."
    Then analizo must report that module <module> has hit = <hit>
    Examples:
      | module    | hit |
      | CSquare   |  0  |
      | CPolygon  |  3  |
      | CTetragon |  2  |

