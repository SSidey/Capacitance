extends Node2D

var actions = {}
var userActions = {}

func _ready():
	set_process_input(true) 
	populatePossibleActions()

func _input(ev):
	if ev is InputEventKey && !$InputTerminal/TextField.has_focus():
		var code = OS.get_scancode_string(ev.scancode)
		if $Player.boundActions.has(code):
			if ev.pressed:
				handle_input_text($Player.boundActions[code])

func _handle_input():
	var text = $InputTerminal/TextField.text
	handle_input_text(text)

func handle_input_text(text):
	var isAction = text.find($Player._name) == 0
	var isFunc = text.find("func") == 0
	if isAction:
		handleAction(text)
	elif isFunc:
		handleFunc(text)

func handleAction(action):
	var text = action.split(".", false, 1)
	if text.size() == 1:
		$InputTerminal/TextField.text = "Invalid declaration"
		return
	var parts = text[1].split("(", true, 1)
	if parts.size() == 2:
		var actionName = parts[0]
		var args = parts[1].trim_suffix(")")
		if $Player._actions.has(actionName) && actions.has(actionName):
			var act = actions[actionName]
			var pArgArray = getArgs(args, act.argCount)
			var argArray = cleanArgs(pArgArray)
			if validParameters(argArray, act.argCount):
				act.funcRef.call_func(argArray)
			else:
				$InputTerminal/TextField.text = "Invalid parameters"
		elif userActions.has(actionName):
			var act = userActions[actionName]
			for funcLine in act.funcLines:
				handleAction(funcLine)
		else:
			$InputTerminal/TextField.text = $Player._name + " can't do that"
	else:
		$InputTerminal/TextField.text = "Invalid declaration"

func handleFunc(function):
	var text = function.trim_prefix("func")
	var parts = text.split("(", true, 1)
	if parts.size() == 2:
		var funcName = trimWhitespace(parts[0])
		var lines = parts[1].split(")", true, 1)
		var args = lines[0].split(",", false)
		var finalLines = trimWhitespace(lines[1]).trim_prefix("{").trim_suffix("}").c_escape()
		var funcsToCall = finalLines.split("\\n", false)
		userActions[funcName] = UserAction.new(funcName, args, funcsToCall)

func trimWhitespace(string):
	return removeWrappingCharacter(string, " ")

func removeWrappingCharacter(string, wrappingCharacter):
	var replacement = removeWrappingPair(string, wrappingCharacter, wrappingCharacter)
	return replacement

func removeWrappingPair(string, first, second):
	var replacement = string.trim_prefix(first).trim_suffix(second)
	return replacement 

func getArgs(args, argCount):
	var count = argCount if argCount == 0 else argCount - 1
	return args.split(",", false, count)

func cleanArgs(argArray: PoolStringArray):
	var args = []
	for arg in argArray:
		if arg != "":
			args.append(arg)	
	for i in range(0, args.size()):
		var noSpaces = trimWhitespace(args[i])
		args[i] = removeWrappingPair(noSpaces, "“", "”")
		args[i] = removeWrappingCharacter(args[i], "\"")
	return args

func validParameters(argArray, expectedCount: int):
	return argArray.size() == expectedCount

func populatePossibleActions():
	populateAction("print", "_print", 1)
	populateAction("move", "_move", 2)
	populateAction("take", "_take", 0)
	populateAction("use", "_use", 0)
	populateAction("help", "_help", 0)
	populateAction("bind", "_bind", 2)

func populateAction(alias, funcName, argCount):
	var funcRef = funcref($Player, funcName)
	actions[alias] = Action.new(funcRef, argCount)

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
        $InputTerminal/TextField.release_focus()
