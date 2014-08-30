{$} = require 'atom'
fs = require 'fs-plus'
FormData = require 'form-data'
request = require 'request'
concat = require('concat-stream')

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
        filetype: type

      @_submitForm "#{@host}#{@uploadPath}", params

    # TODO: rename to fetch
    obtainChannels: ->
      deferred = new $.Deferred()

      request "#{@host}#{@channelsListPath}?token=#{@token}", (error, res, body) =>
        obj = JSON.parse(body)
        if (error)
          deferred.reject(error)
          return
        if (!obj.ok)
          deferred.reject(obj.error)
          return
        if (res.statusCode is not 200)
          deferred.reject({status: res.statusCode})
          return

        @channels = obj.channels
        deferred.resolve(obj.channels)

      deferred

    _submitForm: (url, params) ->
      form = new FormData
      Object.keys(params).forEach (key) =>
        form.append(key, params[key], {filename: 'name'})

      deferred = new $.Deferred()
      form.submit url, (err, res) ->
        write = concat (data)->
          console.log JSON.parse(data)

        res.pipe write

        if res.statusCode == 200
          deferred.resolve(params, res)
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
