{$} = require 'atom'
fs = require 'fs-plus'

module.exports =
  class SlackModel

    atomApiUrl: 'https://slack.com/api/files.upload'

    constructor: (token) ->
      @token = token

    sendTextSnippet: (text, type, channels, comment) ->
      # Code goes here

    sendFile: (fileAbsolutePath, type, channels, commentText) ->
      filename = ''
      console.log fileAbsolutePath
      fs.open(fileAbsolutePath, 'r', (openedFile) =>
        console.log openedFile
        params =
          token: @token
          channels: channels.join(',')
          filename: filename
          title: filename
          initial_comment: commentText
          file: openedFile

        $.post(@atomApiUrl, params)
      )

    # Static
    @buildFileType: (editor) ->
      scopeName = editor.getGrammar().scopeName

      scopeName.match(/.+\.(.+)/)[1]
