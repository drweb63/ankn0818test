# language: en
@test#1
Feature: Test google search

  Scenario: Search on google with button "Search"

    Given open www.google.com
    When type to search field "q" text: "test query"
    And press button with value "Поиск в Google"