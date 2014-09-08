SlackAtomView = require './slack-atom-view'
{Subscriber} = require 'emissary'
SlackModel = require './slack-model'

module.exports =
  slackAtomView: null
  subscriber: null

  activate: (state) ->
    token = atom.config.get('slack-token') or throw new Error('No token found in config, key in cson: slack-token')
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
