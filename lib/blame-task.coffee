path = require 'path'

async = require 'async'
fs = require 'fs-plus'
Git = require 'git-utils'
isBinaryFile = require 'isbinaryfile'

Blame = require './blame'

generateStats = (blameData) ->
  oldestLine = age: Infinity
  newestLine = age: -Infinity
  totalAge = 0
  commits = {}
  authors = {}

  for line in blameData.lines
    oldestLine = line if line.age < oldestLine.age
    newestLine = line if line.age > newestLine.age
    commits[line.commit] = true
    authors[line.name] = true
    totalAge += line.age

  blameData.numberOfCommits = Object.keys(commits).length
  blameData.numberOfAuthors = Object.keys(authors).length
  blameData.averageAge = totalAge / blameData.lines.length
  blameData.oldestLine = oldestLine
  blameData.newestLine = newestLine
  blameData

module.exports = (repoPath) ->
  repo = Git.open(repoPath)
  return unless repo?

  isIgnored = (pathInRepo) -> repo.isIgnored(repo.relativize(pathInRepo))

  pathsToBlame = []
  onFile = (filePath) ->
    if not isIgnored(filePath) and not isBinaryFile(filePath)
      pathsToBlame.push(filePath)
  onDirectory = (directoryPath) -> not isIgnored(directoryPath)

  fs.traverseTreeSync(repo.getWorkingDirectory(), onFile, onDirectory)
  emit('blame-count', pathsToBlame.length)

  queue = async.queue (pathToBlame, callback) ->
    emit('blame-starting', pathToBlame)
    blame = new Blame(pathToBlame)
    lines = []
    blame.on 'line', (line) -> lines.push(line)
    blame.on 'error', ->
    blame.on 'end', ->
      emit('blame-done', generateStats({path: pathToBlame, lines}))
      callback()

  queue.concurrency = 5
  queue.push(pathToBlame) for pathToBlame in pathsToBlame
  queue.drain = @async()
