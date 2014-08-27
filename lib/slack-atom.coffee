SlackAtomView = require './slack-atom-view'
{Subscriber} = require 'emissary'

module.exports =
  slackAtomView: null
  subscriber: null

  activate: (state) ->
    @slackAtomView = new SlackAtomView(state.slackAtomViewState)

    @subscriber = new Subscriber()
    @subscriber.subscribeToCommand atom.workspaceView,
      "slack-atom:upload-file", =>
        @slackAtomView.showUploadFile()

    @subscriber.subscribeToCommand atom.workspaceView,
      "slack-atom:upload-snippet", =>
        @slackAtomView.showUploadSnippet()

  deactivate: ->
    @slackAtomView.destroy()
    @subscriber.unsubscribe()

  serialize: ->
    slackAtomViewState: @slackAtomView.serialize()
