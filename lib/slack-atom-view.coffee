{View, EditorView} = require 'atom'
{$} = require 'atom'
SlackModel = require './slack-model'

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
          @p 'Select channels: '
          @subview 'selectList', new SelectMultipleView
          @div class: "pull-right", =>
            @button outlet: 'publishButton', class: 'btn btn-success', "Publish"
            @button outlet: 'cancelButton', class: 'btn btn-primary', "Cancel"
        @div class: "panel-footer error-message", =>
          @span outlet: 'errorText'

  initialize: (serializeState) ->
    atom.workspaceView.command "slack-atom:toggle", => @toggle()
    @_subscribeEvents()

    @errorText.text 'lol'

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
    @title.hide()
    @selectList.setIsLoadingState true
    @toggle()
    channels = @slackModel.fetchChannels().then (channels) =>
      @selectList.setOptions @_normalizeOptions(channels)

  publish: ->
    activeEditor = atom.workspace.getActiveEditor()

    channels = @_normalizeChannels @selectList.getOptions()
    path = activeEditor.getPath()
    type = SlackModel.buildFileType activeEditor
    comment = @comment.getEditor().getText()

    @slackModel.sendFile(path, type, channels, comment).then (res, message) ->
      console.log res

  _subscribeEvents: ->
    @publishButton.on 'click', => @publish()
    @cancelButton.on 'click', => @toggle()

  _unsubscribeEvents: ->
    @publishButton.off 'click'
    @cancelButton.off 'click'

  _normalizeOptions: (channels)->
    channels.map (channel)->
      obj =
        text: channel.name
        value: channel.id

  _normalizeChannels: (options)->
    channels = []
    options.forEach (option) ->
      channels = channels.concat option.value if option.selected

    channels

class SelectMultipleView extends View

  options: null
  isLoadingState: false

  @content: ->
    @div class: 'select-list', =>
      @div class: 'loading', outlet: 'loadingArea', =>
        @span class: 'loading-message', outlet: 'loading'
      @select  outlet: 'list', multiple: 'multiple'

  initialize: ->
    @list.on 'change', =>
      @_valueSelected()

  setIsLoadingState: (value) ->
    if value
      @list.hide()
      @loadingArea.show()
    else
      @list.show()
      @loadingArea.hide()

  setOptions: (options) ->
    @options = options
    options.forEach (option) =>
      @list.append new Option(option.text, option.value, false, false)
    @setIsLoadingState false

  getOptions: ->
    @options

  _valueSelected: ->
    selectedOptions = $("option:selected", @list)
    @options.forEach (opt) ->
      opt.selected = false

    for option in selectedOptions
      @options.forEach (opt) ->
        if option.value is opt.value
          opt.selected = true

    @options
