SlackModel = require '../lib/slack-model'

{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs-plus'

describe 'SlackModel', ->

  beforeEach: ->
    atom.workspaceView = new WorkspaceView
    atom.workspace = atom.workspaceView.model
    fs.copySync(path.join(__dirname, 'fixtures'), atom.project.getPath())

  describe "get active editor's filetype", ->

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.workspace.open('file.js')

    runs ->
      editor = atom.workspace.getActiveEditor()
      expect(SlackModel.buildFileType(editor)).toBe 'js'
