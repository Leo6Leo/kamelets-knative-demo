Feature: Timer source pipe

  Background:
    Given create Knative broker default

  Scenario: Should create event from timer source
    And Knative service port 8080
    And Knative service "knative-service"
    And Knative event consumer timeout is 5000 ms
    And create Knative event consumer service knative-service
    Given create Knative trigger yaks-trigger on service knative-service with filter on attributes
      | type | org.apache.camel.event.messages |
    # Start Pipe
    Given load Pipe timer-source-pipe.yaml
    Then Camel K integration timer-source-pipe should be running
    # Verify Knative event
    Then expect Knative event data
    """
    { "client": "timer-pipe", "message": "Hello from timer-pipe!" }
    """
    And receive Knative event
      | ce-specversion     | 1.0 |
      | ce-type            | org.apache.camel.event.messages |
      | ce-source          | org.apache.camel |
      | ce-id              | @notEmpty()@ |
      | ce-time            | @matchesDatePattern('yyyy-MM-dd'T'HH:mm:ss')@ |
      | Content-Type       | application/json;charset=UTF-8 |

  Scenario: Remove Pipe
    Given delete Kubernetes service knative-service
    Given delete Pipe timer-source-pipe
