SlackModel = require '../lib/slack-model'

{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs-plus'
nock = require 'nock'


describe 'SlackModel', ->

  [token] = []

  beforeEach ->
    token = 'xoxp-2222042018-2260480908-2577086899-995163'
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    fs.copySync(path.join(__dirname, 'fixtures'), atom.project.getPath())

    nock('https://slack.com')
        .post('/api/files.upload')
        .reply(200)

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
        expect(params.channels).toBe(channels[0])

  it 'sends text to channels', ->
    [slack, type, textToBeSent, commentText, channels] = []
    channels = ['C026J180Q']

    runs ->
      slack = new SlackModel(token)
      type = 'js'
      commentText = 'Awesome file'
      textToBeSent = 'var lol'

    waitsForPromise ->
      slack.sendTextSnippet(textToBeSent, type, channels, commentText)
