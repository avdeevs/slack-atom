SlackAtomView = require './slack-atom-view'

module.exports =
  slackAtomView: null

  activate: (state) ->
    @slackAtomView = new SlackAtomView(state.slackAtomViewState)

  deactivate: ->
    @slackAtomView.destroy()

  serialize: ->
    slackAtomViewState: @slackAtomView.serialize()
