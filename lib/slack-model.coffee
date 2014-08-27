{$} = require 'atom'
fs = require 'fs-plus'
FormData = require 'form-data'
https = require 'http'

module.exports =
  class SlackModel

    host: 'https://slack.com'
    uploadPath: '/api/files.upload'
    channelsListPath: '/api/channels.list'
    token: ''

    channels: null

    constructor: (token) ->
      @token = token
      channels = []

    sendTextSnippet: (text, type, channels, commentText) ->
      params =
        token: @token
        channels: channels.join(',')
        title: 'Snippet'
        initial_comment: commentText
        content: text

      @_submitForm "#{@host}#{@uploadPath}", params


    sendFile: (fileAbsolutePath, type, channels, commentText) ->
      filename = @_parseFileName(fileAbsolutePath)
      fileStream = fs.createReadStream(fileAbsolutePath)

      params =
        token: @token
        channels: channels.join(',')
        title: filename
        initial_comment: commentText
        file: fileStream

      @_submitForm "#{@host}#{@uploadPath}", params

    obtainChannels: ->
      deferred = new $.Deferred()

      $.getJSON("#{@host}#{@channelsListPath}", { token: @token }).then((res)->
        console.log(res)
        if (!res.ok)
          deferred.reject(res.error)
          return

        @channels = res.channels
        deferred.resolve(res.channels)

      ).fail (error)->
        deferred.reject(error)

      deferred


    _submitForm: (url, params) ->
      form = new FormData
      for key, value in params
        form.append(key, value)

      deferred = new $.Deferred()

      form.submit url, (err, message) ->
        if message.statusCode == 200
          deferred.resolve(params, message)
        else
          deferred.reject(err or new Error('Received status other than 200'))

      deferred.promise()


    _parseFileName: (absolutePath) ->
      # what would be on Windows with / ?
      [_, ..., last] = absolutePath.split('/')
      last

    @buildFileType: (editor) ->
      scopeName = editor.getGrammar().scopeName

      scopeName.match(/.+\.(.+)/)[1]
