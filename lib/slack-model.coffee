{$} = require 'atom'

module.exports =
  class SlackModel

    atomApiUrl: ''

    constructor: (token) ->
      # Code goes here

    sendTextSnippet: (text, type) ->
      # Code goes here

    sendFile: (file, type) ->
      # Code goes here

    # Static
    @buildFileType: (editor) ->
      scopeName = editor.getGrammar().scopeName

      console.log scopeName
      scopeName.match(/.+\.(.+)/)[1]
