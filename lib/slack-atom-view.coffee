{View, EditorView} = require 'atom'

module.exports =
class SlackAtomView extends View

  titleText: ''
  commentText: ''
  slackModel: null

  @content: ->
    @div class: 'slack-atom overlay from-top', =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", =>
          @span outlet: 'panelTitle'
        @div class: "panel-body padded", =>
          @subview 'title', new EditorView(mini: true, placeholderText: 'Title')
          @subview 'comment', new EditorView(mini: true, placeholderText: 'Comment text here')
          @div class: "pull-right", =>
            @button outlet: 'publishButton', class: 'btn btn-success', "Publish"
            @button outlet: 'cancelButton', class: 'btn btn-primary', "Cancel"

  initialize: (serializeState) ->
    atom.workspaceView.command "slack-atom:toggle", => @toggle()
    @_subscribeEvents()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

    @_unsubscribeEvents()

  toggle: ->
    console.log "SlackAtomView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)

  setSlackModel: (model)->
    @slackModel = model

  showUploadFile: ->
    @panelTitle.text atom.workspace.getActiveEditor().getPath()
    @toggle()

  publish: ->
    console.log 'Publish'

  _subscribeEvents: ->
    @publishButton.on 'click', => @publish()
    @cancelButton.on 'click', => @toggle()

  _unsubscribeEvents: ->
    #@publishButton.off 'click'
    #@cancelButton.off 'click'
