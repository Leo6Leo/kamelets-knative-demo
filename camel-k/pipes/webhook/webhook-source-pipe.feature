Feature: Webhook source pipe

  Background:
    Given create Knative broker default
    And Knative service port 8081
    And Knative service "knative-service"
    And Knative event consumer timeout is 5000 ms
    And create Knative event consumer service knative-service

  Scenario: Should create event from webhook source
    # Start Pipe
    Given load Pipe webhook-source-pipe.yaml
    Then Camel K integration webhook-source-pipe should be running
    # Invoke webhook
    Given URL: http://localhost:8080/chat
    And HTTP request query parameter message="yaks:urlEncode('Hello from webhook-pipe!')"
    And HTTP request header Content-Type="application/json"
    When send GET
    # Verify Knative event
    Then expect Knative event data
    """
    { "client": "webhook-pipe", "message": "Hello from webhook-pipe!" }
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
    Given delete Pipe webhook-source-pipe
