{$} = require 'atom'
fs = require 'fs-plus'
FormData = require 'form-data'
https = require 'http'

module.exports =
  class SlackModel

    url: 'https://slack.com/api/files.upload'
    token: ''

    constructor: (token) ->
      @token = token

    sendTextSnippet: (text, type, channels, comment) ->
      # Code goes here

    sendFile: (fileAbsolutePath, type, channels, commentText) ->
      filename = @_parseFileName(fileAbsolutePath)
      fileStream = fs.createReadStream(fileAbsolutePath)

      params =
        token: @token
        channels: channels.join(',')
        title: filename
        initial_comment: commentText
        file: fileStream

      form = new FormData
      for key, value in params
        form.append(key, value)

      deferred = new $.Deferred()

      form.submit @url, (err, message) ->
        if message.statusCode == 200
          deferred.resolve(params, message)
        else
          deferred.reject(err or new Error('Received status other than 200'))

      deferred.promise()

    # private
    _parseFileName: (absolutePath) ->
      # what would be on Windows with / ?
      [_, ..., last] = absolutePath.split('/')
      last

    # static
    @buildFileType: (editor) ->
      scopeName = editor.getGrammar().scopeName

      scopeName.match(/.+\.(.+)/)[1]
