((plunker) ->

  plunker.import = (source, options = {}) ->
    self = @
    
    options = _.defaults options,
      wait: true
      silent: false
      defaults: {}
      plunk: new plunker.Plunk
      success: ->
      error: ->
    
    for name, matcher of plunker.importers
      if matcher.test(source)
        strategy = matcher
        break;
    
    if strategy
      strategy.import source, (error, json) ->
        if error then options.error(error)
        else
          files = {}
          _.each json.files, (file) -> files[file.filename] =
            filename: file.filename
            content: file.content
            
          json.index ||= do ->
            filenames = _.keys(json.files)
      
            if "index.html" in filenames then "index.html"
            else
              html = _.filter filenames, (filename) -> /.html?$/.test(filename)
      
              if html.length then html[0]
              else filenames[0]
              

          options.plunk.set
            description: json.description
            files: files
            index: json.index
            #expires: new Cromag(Cromag.now() + 1000).toISOString()
          
          console.log "Plunk", _.clone(options.plunk.attributes)
          
          options.success(options.plunk)
    else
      options.error("Import error", "The source you provided is not a recognized source.")
    @

)(@plunker ||= {})