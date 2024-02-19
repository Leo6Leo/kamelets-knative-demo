Feature: AWS S3 source pipe

  Background:
    Given load variables application.properties
    Given variables
      | aws.s3.key | message.json |
      | aws.s3.message | yaks:readFile('message.json') |
    Given create Knative broker default
    And Knative service port 8080
    And Knative service "knative-service"
    And Knative event consumer timeout is 10000 ms

  Scenario: Should create event from aws-s3 source
    Given create Knative event consumer service knative-service with target port 8080
    Given create Knative trigger yaks-trigger on service knative-service with filter on attributes
      | type | org.apache.camel.event.messages |
    # Start Pipe
    Given load Pipe aws-s3-source-pipe.yaml
    Then Camel K integration aws-s3-source-pipe should be running
    And Camel K integration aws-s3-source-pipe should print Routes startup
    # Create AWS-S3 client
    Given New Camel context
    Given load to Camel registry amazonS3Client.groovy
    # Verify Kamelet source
    Given Camel exchange message header CamelAwsS3Key="${aws.s3.key}"
    Given send Camel exchange to("aws2-s3://${aws.s3.bucketNameOrArn}?amazonS3Client=#amazonS3Client") with body: ${aws.s3.message}
    # Verify Knative event
    Then expect Knative event data
    """
    { "client": "aws-s3", "message": "Hello from AWS S3" }
    """
    And receive Knative event
      | ce-specversion     | 1.0 |
      | ce-type            | org.apache.camel.event.messages |
      | ce-source          | aws.s3.bucket.knative-camel-demo |
      | ce-id              | @notEmpty()@ |
      | ce-time            | @matchesDatePattern('yyyy-MM-dd'T'HH:mm:ss')@ |
      | Content-Type       | application/json;charset=UTF-8 |

  Scenario: Remove Pipe
    Given delete Kubernetes service knative-service
    Given delete Pipe aws-s3-source-pipe
