path = require 'path'
{View} = require 'atom'

module.exports =
class FileView extends View
  @content: ->
    @div class: 'col-md-3 padded', =>
      @div class: 'panel bordered', =>
        @div class: 'panel-heading', outlet: 'filename'
        @div class: 'panel-body padded', =>
          @div =>
            @span class: 'icon icon-git-commit', outlet: 'commits'
            @span ' '
            @span class: 'icon icon-organization', outlet: 'authors'

        @div outlet: 'averageAge'
        @div outlet: 'firstEdited'
        @div outlet: 'lastEdited'

  initialize: ({@path, @lines, numberOfCommits, numberOfAuthors, averageAge, oldestLine, newestLine}) ->
    @filename.text(path.basename(@path))
    @commits.text(numberOfCommits)
    @authors.text(numberOfAuthors)
    @averageAge.text("Avg. age of lines: #{@secondsToDays(averageAge)} days")
    @firstEdited.text("First edited: #{@secondsToDays(oldestLine.age)} days ago")
    @lastEdited.text("Last edited: #{@secondsToDays(newestLine.age)} days ago")

  secondsToDays: (seconds) ->
    Math.round((Date.now() - (seconds * 1000)) / 86400000)
