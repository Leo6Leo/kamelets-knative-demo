Feature: Timer source

  Background:
    Given create Knative broker default
    And Knative service port 8080
    And Knative service "knative-service"
    And Knative event consumer timeout is 5000 ms
    And create Knative event consumer service knative-service

  Scenario Outline: Should create event from <integration-source>.<language>
    # Start Pipe
    Given load Camel K integration <integration-source>.<language>
    Then Camel K integration <integration-source> should be running
    # Verify Knative event
    Then expect Knative event data
    """
    { "client": "<integration-source>", "message": "Hello from <integration-source>!" }
    """
    And receive Knative event
      | ce-specversion     | 1.0 |
      | ce-type            | org.apache.camel.event.messages |
      | ce-source          | org.apache.camel |
      | ce-id              | @notEmpty()@ |
      | ce-time            | @matchesDatePattern('yyyy-MM-dd'T'HH:mm:ss')@ |
      | Content-Type       | application/json;charset=UTF-8 |
    Given delete Kubernetes service knative-service
    Given delete Camel K integration <integration-source>

    Examples:
      | integration-source | language |
      | timer-source       | yaml     |
      | timer-route        | groovy   |
      | timer-source       | groovy   |
