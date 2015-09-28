{
    type: 'object',
    properties: {
      doc: {
        type: 'object',
        required: ['version', 'projectname', 'logo', 'host', 'homepage', 'security', 'description', 'request'],
        properties: {
          version: {
            type: 'integer',
            "default": 1
          },
          projectname: {
            type: 'string',
            "default": "Foo"
          },
          logo: {
            type: 'string',
            "default": "https://github.com/coderofsalvation/coffeerest-api/raw/master/coffeerest.png"
          },
          host: {
            type: 'string',
            "default": "http://mydomain.com"
          },
          homepage: {
            type: 'string',
            "default": "http://mydomain.com/about"
          },
          security: {
            "default": "Requests are authorized by adding a 'X-FOO-TOKEN: YOURTOKEN' http header",
            type: 'string'
          },
          description: {
            "default": "Welcome to the Core API Documentation. The Core API is the heart of Project foo and should never be confused with the public api.",
            type: 'string'
          },
          request: {
            type: 'object',
            "default": {
              curl: "curl -X {{method}} -H 'Content-Type: application/json' -H 'X-FOO-TOKEN: YOURTOKEN' '{{url}}' --data '{{payload}}' "
            }
          }
        }
      }
    }
  };

}
