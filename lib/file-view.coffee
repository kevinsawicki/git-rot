path = require 'path'
{View} = require 'atom'

module.exports =
class FileView extends View
  @content: ->
    @div class: 'col-md-3 file-view', =>
      @div class: 'panel bordered', =>
        @div class: 'panel-heading', =>
          @span outlet: 'filename'
          @div class: 'pull-right', =>
            @span class: 'icon icon-git-commit commits', outlet: 'commits'
            @span class: 'icon icon-person authors', outlet: 'authors'

        @div class: 'panel-body padded', =>
          @div outlet: 'averageAge'
          @div outlet: 'firstEdited'
          @div outlet: 'lastEdited'

  initialize: ({@path, @lines, numberOfCommits, numberOfAuthors, averageAge, oldestLine, newestLine}) ->
    @filename.text(path.basename(@path))
    @commits.text(numberOfCommits)
    @authors.text(numberOfAuthors)
    @averageAge.text("Avg. age of lines: #{@secondsToDays(averageAge)} days")
    @firstEdited.text("First commit: #{@secondsToDays(oldestLine.age)} days ago")
    @lastEdited.text("Last commit: #{@secondsToDays(newestLine.age)} days ago")

  secondsToDays: (seconds) ->
    Math.round((Date.now() - (seconds * 1000)) / 86400000)
