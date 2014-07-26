{$$, ScrollView, Task} = require 'atom'
FileView = require './file-view'

module.exports =
class GitRotView extends ScrollView
  @content: ->
    @div class: 'git-rot pane-item', =>
      @div class: 'block padded', outlet: 'progressArea', =>
        @progress class: 'inline-block', outlet: 'progressBar'
        @span class: 'inline-block text-highlight', outlet: 'progressLabel', 'Scanning repository\u2026'

      @div class: 'padded', =>
        @div class: 'container', outlet: 'container'

  initialize: ({@uri}) ->
    pathsBlamed = []

    task = Task.once require.resolve('./blame-task'), atom.project.getPath(), =>
      @progressArea.hide()

      pathsBlamed.sort (blame1, blame2) ->
        blame2.numberOfCommits - blame1.numberOfCommits

      for pathBlamed, index in pathsBlamed
        if index % 4 is 0
          fileRow = $$ -> @div class: 'row'
          @container.append(fileRow)
        fileRow.append(new FileView(pathBlamed))

    @pathsBlamedCount = 0
    task.on 'blame-count', (pathCount) =>
      @progressBar.attr('max', pathCount)
      @progressBar.attr('value', 0)

    task.on 'blame-starting', (pathBeingBlamed) =>
      @progressLabel.text("Blaming #{atom.project.relativize(pathBeingBlamed)}\u2026")

    task.on 'blame-done', (blamedPath) =>
      @pathsBlamedCount++
      @progressBar.attr('value', @pathsBlamedCount)
      pathsBlamed.push(blamedPath) if blamedPath.lines.length > 0

  serialize: ->
    deserializer: @constructor.name
    uri: @getUri()

  getUri: -> @uri

  getTitle: -> 'Git Rot'

  getIconName: -> 'history'
