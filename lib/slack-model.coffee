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
      if channels.length is 0
        return new $.Deferred().reject(new Error('No channels selected'))

      params =
        token: @token
        channels: channels.join(',')
        title: 'Snippet'
        initial_comment: commentText
        content: text
        filename: "snippet.#{type}"

      @_submitForm "#{@host}#{@uploadPath}", params

    sendFile: (fileAbsolutePath, type, channels, commentText) ->
      if channels.length is 0
        return new $.Deferred().reject(new Error('No channels selected'))

      path = String(fileAbsolutePath)
      filename = @_parseFileName(path)
      fileStream = fs.createReadStream(path)

      params =
        token: @token
        channels: channels.join(',')
        title: filename
        initial_comment: commentText
        file: fileStream
        filetype: type

      @_submitForm "#{@host}#{@uploadPath}", params

    fetchChannels: ->
      deferred = new $.Deferred()

      request.get
        url: "#{@host}#{@channelsListPath}?token=#{@token}",
        timeout: 5000
      , (error, res, body) =>
        if error
          return deferred.reject(error).promise()

        obj = JSON.parse(body)

        switch
          when not obj.ok
            deferred.reject(obj.error)
          when res.statusCode is not 200
            deferred.reject({status: res.statusCode})
          else
            @channels = obj.channels
            deferred.resolve(obj.channels)

      deferred.promise()

    _submitForm: (url, params) ->
      form = new FormData
      Object.keys(params).forEach (key) ->
        form.append(key, params[key]) if params[key]

      deferred = new $.Deferred()
      form.submit url, (err, res) ->
        write = concat (data)->
          respBody = JSON.parse data
          switch
            when not (res.statusCode is 200)
              deferred.reject(err or new Error("Received status other than 200: #{res.statusCode}"))
            when error = respBody.error
              deferred.reject(new Error("Error: #{error}"))
            else
              deferred.resolve(params, res)

        res.pipe write

      deferred.promise()

    _parseFileName: (absolutePath) ->
      # what would be on Windows with / ?
      [_, ..., last] = absolutePath.split('/')
      last

    @buildFileType: (editor) ->
      scopeName = editor.getGrammar().scopeName

      scopeName.match(/.+\.(.+)/)[1]
