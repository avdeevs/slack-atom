{View} = require 'atom'

module.exports =
class SlackAtomView extends View

  titleText: ''
  commentText: ''
  slackModel: null

  @content: ->
    @div class: 'slack-atom overlay from-top', =>
      @div "The SlackAtom package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "slack-atom:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "SlackAtomView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
