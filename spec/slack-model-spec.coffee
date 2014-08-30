SlackModel = require '../lib/slack-model'

{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs-plus'
nock = require 'nock'

nock.disableNetConnect()

describe 'SlackModel', ->

  [token] = []

  beforeEach ->
    token = 'xoxp-2222042018-2260480908-2577086899-995163'
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    fs.copySync(path.join(__dirname, 'fixtures'), atom.project.getPath())

    nock.cleanAll()
    nock('https://slack.com')
        .post('/api/files.upload')
        .reply(200, {
          ok: true,
          object: {}
        })

  it "gets active editor's filetype", ->
    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('file.js')

    runs ->
      editor = atom.workspace.getActiveEditor()
      expect(SlackModel.buildFileType(editor)).toBe 'js'

  it 'sends file to channels', ->
    [slack, type, pathToFile, commentText, channels] = []
    channels = ['C026J180Q']

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('file.js')

    runs ->
      slack = new SlackModel(token)
      editor = atom.workspace.getActiveEditor()
      type = SlackModel.buildFileType(editor)
      commentText = 'Awesome file'
      pathToFile = path.join(atom.project.getPath(), 'file.js')

    waitsForPromise ->
      slack.sendFile(pathToFile, type, channels, commentText).then (params) ->
        expect(params.title).toBe('file.js')
        expect(params.token).toBe(token)
        expect(params.initial_comment).toBe(commentText)
        expect(params.file).not.toBe(null)
        expect(params.filetype).toBe(type)
        expect(params.channels).toBe(channels[0])

  it 'fails to send file to channel due to bad token', ->
    [slack, type, pathToFile, commentText, channels, promise] = []
    channels = ['C026J180Q']
    token = 'invalidtoken'

    nock.cleanAll()
    nock('https://slack.com')
        .post('/api/files.upload')
        .reply(200, {
          ok: false,
          error: 'not_authed'
        })

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('file.js')

    runs ->
      slack = new SlackModel(token)
      editor = atom.workspace.getActiveEditor()
      type = SlackModel.buildFileType(editor)
      commentText = 'Awesome file'
      pathToFile = path.join(atom.project.getPath(), 'file.js')
      promise = slack.sendFile(pathToFile, type, channels, commentText)

    waitsFor ->
      (promise != null) && (promise.state() is 'rejected')

    runs ->
      promise.fail (error) ->
        expect(error.message).toBe 'Error: not_authed'

  it 'fails to send file to channel due to http error', ->
    [slack, type, pathToFile, commentText, channels, promise] = []
    channels = ['C026J180Q']

    nock.cleanAll()
    nock('https://slack.com')
        .post('/api/files.upload')
        .reply(400, {})

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('file.js')

    runs ->
      slack = new SlackModel(token)
      editor = atom.workspace.getActiveEditor()
      type = SlackModel.buildFileType(editor)
      pathToFile = path.join(atom.project.getPath(), 'file.js')
      promise = slack.sendFile(pathToFile, type, channels, commentText)

    waitsFor ->
      (promise != null) && (promise.state() is 'rejected')

    runs ->
      promise.fail (error) ->
        expect(error.message).toBe 'Received status other than 200: 400'


  it 'sends text to channels', ->
    [slack, type, textToBeSent, commentText, channels] = []
    channels = ['C026J180Q']

    runs ->
      slack = new SlackModel(token)
      type = 'js'
      commentText = 'Awesome file'
      textToBeSent = 'var lol'

    waitsForPromise ->
      slack.sendTextSnippet(textToBeSent, type, channels, commentText).then (params) ->
        expect(params.token).toBe(token)
        expect(params.title).toBe('Snippet')
        expect(params.content).toBe(textToBeSent)
        expect(params.initial_comment).toBe(commentText)
        expect(params.channels).toBe(channels[0])

  it 'fetches channels', ->
    slack = new SlackModel(token)

    nock('https://slack.com')
        .get("/api/channels.list?token=#{token}")
        .reply(200,
          ok: true
          channels: new Array(13)
        )

    waitsForPromise ->
      slack.fetchChannels().then (channels)->
        expect(channels.length).toBe(13)
