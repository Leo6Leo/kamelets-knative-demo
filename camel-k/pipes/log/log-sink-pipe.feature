Feature: Log sink pipe

  Background:
    Given Knative broker URL: http://localhost:8080/events/org.apache.camel.event.messages

  Scenario: Should consume event from Knative broker
    # Start Pipe
    Given load Pipe log-sink-pipe.yaml
    Then Camel K integration log-sink-pipe should be running
    # Send Knative event
    Then Knative event data
    """
    { "client": "yaks-test", "message": "Hello from yaks-test!" }
    """
    And send Knative event
      | ce-specversion     | 1.0 |
      | ce-type            | org.apache.camel.event.messages |
      | ce-source          | org.apache.camel |
      | ce-id              | yaks:randomUUID() |
      | ce-time            | yaks:currentDate('yyyy-MM-dd'T'HH:mm:ss') |
      | Content-Type       | application/json;charset=UTF-8 |
    Then Camel K integration log-sink-pipe should print Hello from yaks-test!

  Scenario: Remove Pipe
    Given delete Pipe log-sink-pipe
