Feature: Webhook source route

  Background:
    Given create Knative broker default
    And Knative service port 8080
    And Knative service "knative-service"
    And Knative event consumer timeout is 5000 ms

  Scenario: Should create event from webhook source
    And create Knative event consumer service knative-service with target port 8080
    Given create Knative trigger yaks-trigger on service knative-service with filter on attributes
      | type | org.apache.camel.event.messages |
    # Start Pipe
    Given load Camel K integration webhook-source.yaml
    Then Camel K integration webhook-source should be running
    And Camel K integration webhook-source should print Routes startup
    # Invoke webhook
    Given URL: yaks:resolveURL('webhook-source','8081')
    And HTTP request query parameter client="webhook-source"
    And HTTP request query parameter message="yaks:urlEncode('Hello from webhook-source!')"
    And HTTP request header Content-Type="application/json"
    When send GET /chat
    And Camel K integration webhook-source should print Hello from webhook-source!
    # Verify Knative event
    Then expect Knative event data
    """
    { "client": "webhook-source", "message": "Hello from webhook-source!" }
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
    Given delete Camel K integration webhook-source
