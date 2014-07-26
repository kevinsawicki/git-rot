path = require 'path'
{spawn} = require 'child_process'
{EventEmitter} = require 'events'

es = require 'event-stream'

module.exports =
class Blame extends EventEmitter
  constructor: (@path) ->
    @once 'newListener', =>
      process.nextTick => @start()

  start: ->
    command = 'git'
    args = ['blame', '-C', '-M', '--line-porcelain', 'HEAD', '--', @path]
    options = cwd: path.dirname(@path)
    blameProcess = spawn(command, args, options)

    blameProcess.on 'error', (error) => @emit('error', error)

    stdoutClosed = false
    stderrClosed = false
    emitEnd = => @emit('end') if stdoutClosed and stderrClosed

    lineDetails = null
    blameProcess.stdout.pipe(es.split()).on 'data', (line) =>
      if lineStart = /^([a-f0-9]{40}) \d+ (\d+)/.exec(line)
        lineDetails =
          commit: lineStart[1]
          number: parseInt(lineStart[2])
      else if authorName = /^author (.*)$/.exec(line)
        lineDetails.name = authorName[1]
      else if authorEmail = /^author-mail <(.*)>$/.exec(line)
        lineDetails.email = authorEmail[1]
      else if authorTime = /^author-time (\d+)$/.exec(line)
        lineDetails.age = parseInt(authorTime[1])
      else if lineText = /^\s+(.*)$/.exec(line)
        @emit('line', lineDetails)

    blameProcess.stdout.on 'close', =>
      stdoutClosed = true
      emitEnd()

    standardError = ''
    blameProcess.stderr.pipe(es.split()).on 'data', (line) =>
      standardError += line

    blameProcess.stderr.on 'close', =>
      stderrClosed = true
      @emit('error', new Error(standardError)) if standardError
      emitEnd()
