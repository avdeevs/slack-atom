{$} = require 'atom'
fs = require 'fs-plus'

module.exports =
  class SlackModel

    atomApiUrl: 'https://slack.com/api/files.upload'
    token: ''

    constructor: (token) ->
      @token = token

    sendTextSnippet: (text, type, channels, comment) ->
      # Code goes here

    sendFile: (fileAbsolutePath, type, channels, commentText) ->
      filename = ''

      fileStream = fs.createReadStream(fileAbsolutePath)

      formData = new FormData
      formData.append('token', @token)
      formData.append('channels', channels)
      formData.append('title', filename)
      formData.append('initial_comment', commentText)
      formData.append('file', fileStream)

      $.ajax
        url: @atomApiUrl
        data: formData
        processData: false
        contentType: false
        type: 'POST'

    # Static
    @buildFileType: (editor) ->
      scopeName = editor.getGrammar().scopeName

      scopeName.match(/.+\.(.+)/)[1]
