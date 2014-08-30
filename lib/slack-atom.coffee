SlackAtomView = require './slack-atom-view'
{Subscriber} = require 'emissary'
SlackModel = require './slack-model'

module.exports =
  slackAtomView: null
  subscriber: null

  activate: (state) ->
    token = 'xoxp-2222042018-2260480908-2600418459-fc13b2'
    slackModel = new SlackModel(token)

    @slackAtomView = new SlackAtomView(state.slackAtomViewState)
    @slackAtomView.setSlackModel slackModel

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
