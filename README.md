coffeerest-api
==============
Unfancy rest apis

<img alt="" src="https://github.com/coderofsalvation/coffeerest-api/raw/master/coffeerest.png" width="20%" />

## Ouch! Is it that simple?

Your `model.coffee` specification 

    module.exports = 
      name: "project foo"
      resources:
        '/book/:category':
          post:
            description: 'adds a book'
            payload:
              foo:  
                type: "string", 
                minLength: 5, 
                required: true 
                default: "foobar"            <-------- 

## Usage 

    npm install coffeerest-api
    npm install coffeerest-api-doc

for servercode see [coffeerest-api](https://www.npmjs.com/package/coffeerest-api)

## Example output: markdown

    $ coffee server.coffee &
    $ curl -H 'Content-Type: application/json' http://localhost:8080/v1/doc/markdown 
    JSON API
    ========
    Documentation of project foo /v1 API endpoints

    ### GET /v1/books/:action

    do something with a book

    ### POST /v1/book

    adds a book

    Example payload:

         {
           "foo": "bar"
         }

    JSON Schema:

         {
           "foo": {
             "type": "string",
             "minLength": 5,
             "required": true,
             "default": "bar"
           }
         }



