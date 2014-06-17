vm = require("vm")
stringify = require("json-stable-stringify")

prettify = (editor, sorted) ->
  wholeFile = editor.getGrammar().name == 'JSON'

  if wholeFile
    text = editor.getText()
    editor.setText(formatter(text, sorted))
  else
    text = editor.replaceSelectedText({}, (text) ->
      formatter(text, sorted)
    )

formatter = (text, sorted) ->
  editorSettings = atom.config.getSettings().editor
  if editorSettings.softTabs?
    space = Array(editorSettings.tabLength + 1).join(" ")
  else
    space = "\t"

  parsed = parseJSON(text)
  if !parsed
    return text

  if sorted
    return stringify(parsed, { space: space })
  else
    return JSON.stringify(parsed, null, space)

parseJSON = (str) ->
  if validJSON(str)
    return JSON.parse(str)
  else
    try
      vm.runInThisContext('newObject='+str)
      if newObject instanceof Error
        return false
      else
        return JSON.parse(JSON.stringify(newObject))
    catch err
      return false

validJSON = (str) ->
  try
    JSON.parse(str)
    return true
  catch err
    return false

module.exports =
  activate: ->
    atom.workspaceView.command 'pretty-json:prettify', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      prettify(editor)
    atom.workspaceView.command 'pretty-json:sort-and-prettify', '.editor', ->
      editor = atom.workspaceView.getActivePaneItem()
      prettify(editor, true)
