SlackModel = require '../lib/slack-model'

{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs-plus'

describe 'SlackModel', ->

  [token] = []

  beforeEach ->
    token = 'xoxp-2222042018-2260480908-2577086899-995163'
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    fs.copySync(path.join(__dirname, 'fixtures'), atom.project.getPath())

  it "gets active editor's filetype", ->
    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('file.js')

    runs ->
      editor = atom.workspace.getActiveEditor()
      expect(SlackModel.buildFileType(editor)).toBe 'js'

  it 'sends file to @User', ->
    [slack, type, response] = []
    channels = ['general', 'daily-ops']

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('file.js')

    runs ->
      slack = new SlackModel(token)
      editor = atom.workspace.getActiveEditor()
      type = SlackModel.buildFileType(editor)

    waitsForPromise ->
      commentText = 'Awesome file'

      pathToFile = path.join(atom.project.getPath(), 'file.js')
      response = slack.sendFile(pathToFile, type, channels, commentText)

    runs ->
      console.log(JSON.stringify(response))
