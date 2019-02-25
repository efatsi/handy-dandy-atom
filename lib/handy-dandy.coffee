{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'handy-dandy:copy-line': => @copyLine()
      'handy-dandy:copy-path': => @copyPath()
      'handy-dandy:generate-numbers': => @generateNumbers()
      'handy-dandy:add-helper-method': => @addHelperMethod()
      'handy-dandy:set-tabs-to-2': => @setTabTo(2)
      'handy-dandy:set-tabs-to-4': => @setTabTo(4)

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

  generateNumbers: ->
    if @editor()
      buffer = @editor().getBuffer()
      selections = @editor().getSelectedBufferRanges()

      # Order by row, then column if on the same row
      selections = selections.sort (a, b) ->
        if a.start.row - b.start.row != 0
          a.start.row - b.start.row
        else
          a.start.column - b.start.column

      # Reverse selections so buffer is modified bottom up
      # Doing so means modifying one won't mess up later selections
      for selection, index in selections.reverse()
        # Only log the first modification in the undo set, skip the rest
        opts = {undo: "skip"}
        if index == 0
          opts = {}

        number = selections.length - index

        buffer.setTextInRange(selection, (number).toString(), opts)

  addHelperMethod: ->
    if @editor()
      selection = @editor().getSelections()[0]
      methodName = selection.getText()
      mode = @editor().getBuffer().getLanguageMode()

      methodRange = mode.getRangeForSyntaxNodeContainingRange(selection.getBufferRange())

      @editor().setCursorBufferPosition(methodRange.end)
      @editor().insertNewline()
      @editor().insertText("helper_method :" + methodName, {undo: "skip"})

  setTabTo: (number) ->
    atom.config.set("editor.tabLength", number)

  editor: ->
    atom.workspace.getActiveTextEditor()
