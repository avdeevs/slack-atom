{View, EditorView} = require 'atom'
{$} = require 'atom'
SlackModel = require './slack-model'

module.exports =
class SlackAtomView extends View

  titleText: ''
  commentText: ''
  slackModel: null
  mode: 'file'

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
        @div outlet: 'footer', class: "panel-footer error-message", =>
          @span outlet: 'errorText', class: 'danger'

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
      @footer.hide()

  setSlackModel: (model)->
    @slackModel = model

  showUploadFile: ->
    @panelTitle.text atom.workspace.getActiveEditor().getPath()
    @mode = 'file'
    @_fetchChannelsAndRenderModal()

  showUploadSnippet: ->
    @panelTitle.text 'Uploading snippet'
    @mode = 'text'
    @_fetchChannelsAndRenderModal()

  publish: ->
    activeEditor = atom.workspace.getActiveEditor()

    channels = @_normalizeChannels @selectList.getOptions()
    fileType = SlackModel.buildFileType activeEditor
    console.log fileType

    switch @mode
      when 'file' then @_publishFile(activeEditor, fileType, channels)
      when 'text' then @_publishTextSnippet(activeEditor, fileType, channels)

  _publishFile: (activeEditor, type, channels) ->
    comment = @comment.getEditor().getText()
    path = activeEditor.getPath()

    @slackModel.sendFile(path, type, channels, comment)
      .then (res, message) =>
        @toggle()
      .fail (error) =>
        @footer.show()
        @errorText.text(error)

  _publishTextSnippet: (activeEditor, type, channels) ->
    text = activeEditor.getSelectedText()
    unless text
      @_showErrorMessage 'Text to be sent is empty'
      return

    comment = @comment.getEditor().getText()

    @slackModel.sendTextSnippet(text, type, channels, comment)
      .then (res, message) =>
        @toggle()
      .fail (error) =>
        @_showErrorMessage error

  _fetchChannelsAndRenderModal: ->
    @title.hide()
    @selectList.setIsLoadingState true
    @toggle()
    @slackModel.fetchChannels()
    .then (channels) =>
      @selectList.setOptions @_normalizeOptions(channels)
    .fail (error) =>
      @_showErrorMessage error

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

  _showErrorMessage: (error)->
    @footer.show()
    @errorText.text(error)

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
    @_valueSelected()

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
