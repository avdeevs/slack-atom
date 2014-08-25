{$} = require 'atom'

module.exports =
  class SlackModel

    atomApiUrl: 'https://slack.com/api/files.upload'

    constructor: (token) ->
      @token = token

    sendTextSnippet: (text, type, channels) ->
      # Code goes here

    sendFile: (file, type, channels) ->
      $().promise()

    # Static
    @buildFileType: (editor) ->
      scopeName = editor.getGrammar().scopeName

      scopeName.match(/.+\.(.+)/)[1]
