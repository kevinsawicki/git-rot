path = require 'path'
{View} = require 'atom'
timeago = require 'timeago'

module.exports =
class FileView extends View
  @content: ->
    @div class: 'col-md-3 file-view', =>
      @div class: 'panel bordered', =>
        @div class: 'panel-heading', =>
          @a outlet: 'filename'
          @div class: 'pull-right', =>
            @span class: 'icon icon-git-commit commits', outlet: 'commits'
            @span class: 'icon icon-person authors', outlet: 'authors'

        @div class: 'panel-body padded', =>
          @div outlet: 'lineCount'
          @div outlet: 'averageAge'
          @div outlet: 'firstEdited'
          @div outlet: 'lastEdited'

  initialize: ({@path, @lines, numberOfCommits, numberOfAuthors, averageAge, oldestLine, newestLine}) ->
    @filename.text(path.basename(@path))
    @commits.text(numberOfCommits)
    @authors.text(numberOfAuthors)

    @lineCount.text("#{@lines.length} lines")
    @averageAge.text("Avg. age of lines: #{@millisecondsToDays(averageAge)} days")

    oldestCommit = new Date(oldestLine.age)
    @firstEdited.text("First commit #{timeago(oldestCommit)}").attr('title', oldestCommit)

    latestCommit = new Date(newestLine.age)
    @lastEdited.text("Last commit #{timeago(latestCommit)}").attr('title', latestCommit)

    @filename.on 'click', =>
      atom.workspace.open(@path)
      false

  millisecondsToDays: (seconds) ->
    Math.round((Date.now() - (seconds)) / 86400000)
