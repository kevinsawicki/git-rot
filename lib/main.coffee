GitRotView = null

viewUri = 'atom://git-rot'
createView = (state) ->
  GitRotView ?= require './git-rot-view'
  new GitRotView(state)

atom.deserializers.add
  name: 'GitRotView'
  deserialize: (state) -> createView(state)

module.exports =
  activate: ->
    atom.workspace.registerOpener (filePath) ->
      createView(uri: viewUri) if filePath is viewUri

    atom.workspaceView.command 'git-rot:view', -> atom.workspaceView.open(viewUri)
