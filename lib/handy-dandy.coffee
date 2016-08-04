{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'handy-dandy:copy-line': => @copyLine()
      'handy-dandy:copy-path': => @copyPath()

  deactivate: ->
    @subscriptions.dispose()

  copyLine: ->
    if @editor()
      fullPath   = atom.workspace.getActiveTextEditor().getPath()
      localPath  = atom.project.relativizePath(fullPath)[1]
      lineNumber = @editor().getCursorBufferPosition().row + 1

      atom.clipboard.write(localPath + ":" + lineNumber)

  copyPath: ->
    if @editor()
      fullPath   = atom.workspace.getActiveTextEditor().getPath()
      localPath  = atom.project.relativizePath(fullPath)[1]

      atom.clipboard.write(localPath)

  editor: ->
    atom.workspace.getActiveTextEditor()
