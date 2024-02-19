Feature: Google Sheets sink pipe

  Background:
    Given load variables application.properties
    And variable range = "Messages!A:B"

  Scenario: Should consume event from Knative broker
    # Start Pipe
    Given load Pipe google-sheets-sink-pipe.yaml
    And Camel K integration google-sheets-sink-pipe should be running
    When Camel K integration google-sheets-sink-pipe should print Routes startup
    # Clear Google Sheets spreadsheet
    When send Camel exchange to("google-sheets:data/clear?spreadsheetId=${sheets.spreadsheetId}&range=${range}&clientId=${sheets.clientId}&clearValuesRequest=#class:com.google.api.services.sheets.v4.model.ClearValuesRequest&accessToken=${sheets.accessToken}&refreshToken=${sheets.refreshToken}&clientSecret=${sheets.clientSecret}")
    # Create Google Sheets stream consumer
    And Camel route googleSheetsStream.groovy
    """
    from("google-sheets-stream://${sheets.spreadsheetId}?range=${range}&clientId=${sheets.clientId}&accessToken=${sheets.accessToken}&refreshToken=${sheets.refreshToken}&clientSecret=${sheets.clientSecret}")
      .transform(new org.apache.camel.spi.DataType("google-sheets:application-x-struct"))
      .to("log:info")
      .to("seda:sheets-stream")
    """
    And sleep 10sec
    # Send Knative event
    Then Knative event data
    """
    { "client": "yaks-test", "message": "Hello from yaks-test!" }
    """
    And send Knative event
      | ce-specversion     | 1.0 |
      | ce-type            | org.apache.camel.event.messages |
      | ce-source          | org.apache.camel |
      | ce-id              | yaks:randomString(15, UPPERCASE, true)-0000000000000000 |
      | ce-time            | yaks:currentDate(yyyy-MM-dd'T'HH:mm:ss).000Z |
      | Content-Type       | application/json;charset=UTF-8 |
      | Accept             | application/json |
      | Accept-Encoding    | UTF-8 |
    Then Camel K integration google-sheets-sink-pipe should print Hello from yaks-test!
    # Verify Google Sheets stream consumer has received event
    And receive Camel exchange from("seda:sheets-stream") with body: [{"A":"yaks-test","B":"Hello from yaks-test!"}]

  Scenario: Remove Pipe
    Given delete Pipe google-sheets-sink-pipe
