Feature: merge markdown marketplace content files into en.json

  Background: create a new zendesk app
    Given an app is created in directory "tmp/aruba"
    Given .md files in "tmp/aruba/translations"
    And I move to the app directory

  Scenario: merge marketplace content for a zendesk app by running 'zat merge_markdown -o' command
    When I run the command "zat merge_markdown -o" to package the app
    And the command output should contain "Reading installation_instructions.md"
    And the command output should contain "Reading long_description.md"
    And the command output should contain "Overwriting the current value of long_description in en.json"
    And the command output should contain "Overwriting the current value of installation_instructions in en.json"
    And the command output should contain "Writing to en.json"
    Then the app file "translations/en.json" is created with:
"""
{"app": {"name": "Zen Tunes","short_description": "Play the famous zen tunes in your help desk.","long_description": "# Description \\n What a good app","installation_instructions": "# Instructions \\n _cool markdown_\\n\\n [markdown is](very cool)"}}
"""
   And I reset the working directory

  Scenario: merge marketplace content for a zendesk app by running 'zat merge_markdown' command
    When I run the command "zat merge_markdown" to package the app
    And the command output should contain "Reading long_description.md"
    Then the command output should contain "You already have a value for long_description in en.json. Please remove it or use the -o flag"
   And I reset the working directory
