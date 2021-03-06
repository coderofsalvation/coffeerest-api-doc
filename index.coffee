defaults = require 'json-schema-defaults'
mustache = require 'mustache'
util     = require 'util'
clone    = (obj) -> JSON.parse( JSON.stringify obj )

module.exports = (server, model, lib, urlprefix ) ->

  @.markdown = (resources, urlprefix, model) ->
    resource = clone resources; model = clone model
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
    description += "\n"+model.doc.description+"\n\n"+model.doc.security+"\n\n"
    restext     = ""
    for url,methods of resources
      url = urlprefix+url
      for method,resource of methods
        restext += "### "+method.toUpperCase()+" "+url+line
        restext += (if resource.description? then resource.description+line else "no description (yet)"+line)
        continue if not resource.payload? or not method?
        restext += "Example payload:"+line+indent( 4, JSON.stringify(defaults( { type: "object", properties: resource.payload}),null,2) )+line
        restext += "> "+ resource.notes+ "\n" if resource.notes?
        restext += "JSON Schema:"+line+indent( 4, JSON.stringify(resource.payload,null,2) )+line
    return header+description+restext
    
  @.html = (resources, urlprefix, model) ->
    resource = clone resources; model = clone model
    template = require('fs').readFileSync(__dirname+"/mustache/index.html").toString()
    vars     = model.doc 
    vars.replyschema_payload = JSON.stringify( defaults model.replyschema, null, 2 )
    vars.host += urlprefix 
    vars.replyschema_codes = JSON.stringify model.replyschema.messages, null, 2
    vars.resources = {}
    for url,methods of resources
      urlparts = url.split("/")
      resource = urlparts[1]
      vars.resources[ resource ] = { resourcename: resource, children: [] } if not vars.resources[ resource ]?
      methods_flat = []; 
      for name,method of methods
        schema = []; 
        payload = false 
        payload_flat = false;
        if method.payload?
          method.default = method.default || {}
          schema.push { field:k, schema: util.inspect(v) } for k,v of method.payload 
          payload = JSON.stringify defaults({ default: method.default, type: 'object', properties: method.payload }),null,2
          payload_flat = JSON.stringify defaults({ type: 'object', properties: method.payload })

        query_params = []; 
        if method.query_params?
          for queryvar, v of method.query_params
            v.values = v.values.join(',')
            query_params.push { varname: queryvar, info: v }
          console.log JSON.stringify query_params,null,2
        requestors = []; for type,code of vars.request
          requestors.push 
            type: type 
            code: mustache.render( code, { 
              url: vars.host+url
              method: name,
              payload: payload_flat 
            })
        methods_flat.push 
          id: String(name+vars.host+url).replace(/[\W_]+/g,"_")
          methodname: name
          description: method.description 
          notes: ( if method.notes? then method.notes else false )
          schema:  schema
          query_params: (if query_params.length then query_params else undefined )
          requestors: requestors
          url: url
          payload: payload 
      vars.resources[ resource ].children.push { name: resource, url: url, methods: methods_flat }
      #for method,resource of methods
      #  #restext += "### "+method.toUpperCase()+" "+url+line
      #  #restext += (if resource.description? then resource.description+line else "no description (yet)"+line)
      #  #continue if not resource.payload? or not method?
      #  #restext += "Example payload:"+line+indent( 4, JSON.stringify(defaults( { type: "object", properties: resource.payload}),null,2) )+line
      #  #restext += "JSON Schema:"+line+indent( 4, JSON.stringify(resource.payload,null,2) )+line
    # convert to array since mustache loves arrays
    arr = []
    arr.push r for k,r of vars.resources 
    vars.resources = arr
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

  return @
