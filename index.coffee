defaults = require 'json-schema-defaults'
mustache = require 'mustache'

module.exports = (server, model, lib, urlprefix ) ->

  @.markdown = (resources, urlprefix, model) ->
    indent = (spaces,str) ->
      return str if str == undefined
      lines = str.split("\n");
      blank = ""
      blank = blank + " " for i in [0..spaces]
      ( lines[k] = blank + line for k,line of lines )
      return lines.join("\n")

    line        = "\n\n"
    header      = "JSON API\n========"+line
    description = "Documentation of "+model.name+" "+urlprefix+" API endpoints"+line
    restext     = ""
    for url,methods of resources
      url = urlprefix+url
      for method,resource of methods
        restext += "### "+method.toUpperCase()+" "+url+line
        restext += (if resource.description? then resource.description+line else "no description (yet)"+line)
        continue if not resource.payload? or not method?
        restext += "Example payload:"+line+indent( 4, JSON.stringify(defaults( { type: "object", properties: resource.payload}),null,2) )+line
        restext += "JSON Schema:"+line+indent( 4, JSON.stringify(resource.payload,null,2) )+line
    return header+description+restext
    
  @.html = (resources, urlprefix, model) ->
    #for url,methods of resources
    #  url = urlprefix+url
    #  for method,resource of methods
    #    restext += "### "+method.toUpperCase()+" "+url+line
    #    restext += (if resource.description? then resource.description+line else "no description (yet)"+line)
    #    continue if not resource.payload? or not method?
    #    restext += "Example payload:"+line+indent( 4, JSON.stringify(defaults( { type: "object", properties: resource.payload}),null,2) )+line
    #    restext += "JSON Schema:"+line+indent( 4, JSON.stringify(resource.payload,null,2) )+line
    #return header+description+restext
    template = require('fs').readFileSync(__dirname+"/mustache/index.html").toString()
    vars     = model.doc 
    vars.replyschema_payload = JSON.stringify( defaults model.replyschema, null, 2 )
    vars.host += urlprefix 
    vars.replyschema_codes = JSON.stringify model.replyschema.messages, null, 2
    return mustache.render template, vars

  # register markdown url
  console.log "registering REST resource: "+urlprefix+"/doc/markdown"
  ( (urlprefix,model,me) ->
      server.get urlprefix+"/doc/markdown", (req,res,next) ->
          body = me.markdown model.resources, urlprefix, model
          res.writeHead 200, 
            'Content-Length': Buffer.byteLength(body),
            'Content-Type': 'text/plain'
          res.write(body)
          res.end()
          next()
  )(urlprefix,model,@)

  # register html url
  console.log "registering REST resource: "+urlprefix+"/doc/html"
  ( (urlprefix,model,me) ->
      server.get urlprefix+"/doc/html", (req,res,next) ->
          body = me.html model.resources, urlprefix, model
          res.writeHead 200, 
            'Content-Length': Buffer.byteLength(body),
            'Content-Type': 'text/html'
          res.write(body)
          res.end()
          next()
  )(urlprefix,model,@)
