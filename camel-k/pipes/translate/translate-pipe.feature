Feature: Translate pipe

  Background:
    Given HTTP server "libre-translate"
    And start HTTP server

  Scenario: Should translate message
    # Start Pipe
    Given Camel K integration property file application.properties
    Given load Pipe translate-pipe.yaml
    And Camel K integration translate-pipe should be running
    When Camel K integration translate-pipe should print Routes startup
    # Expect Http call on translate service
    Given HTTP request body
    """
    {
      "q": "Hello from yaks-test!",
      "source": "auto",
      "target": "it",
      "format": "text",
      "api_key": ""
    }
    """
    When receive POST /translate
    Then HTTP response body
    """
    {
        "detectedLanguage": {
            "confidence": 99,
            "language": "en"
        },
        "translatedText": "Ciao da Yaks-test!"
    }
    """
    Then send HTTP 200 OK
    # Verify pipe log output
    Then Camel K integration translate-pipe should print yaks-test: Ciao da Yaks-test!

  Scenario: Remove Pipe
    Given delete Pipe translate-pipe
