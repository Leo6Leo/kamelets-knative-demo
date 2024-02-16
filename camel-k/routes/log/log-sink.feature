Feature: Log sink

  Scenario: Should consume event from Knative broker
    # Start Pipe
    Given load Camel K integration log-sink.yaml
    Then Camel K integration log-sink should be running
    Then Camel K integration log-sink should print Routes startup
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
    Then Camel K integration log-sink should print Hello from yaks-test!

  Scenario: Remove Pipe
    Given delete Camel K integration log-sink
