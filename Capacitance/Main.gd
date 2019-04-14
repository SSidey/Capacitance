extends Node2D

var actions = {}

func _ready():
	populatePossibleActions()

func _handle_input():
	var text = $InputTerminal/TextField.text
	var split = text.split(".", true, 2)
	if split[0] == $Player._name && split.size() > 1:
		handleFunction(split[1])

func handleFunction(function):
	var parts = function.split("(", true, 2)
	if parts.size() == 2:
		var action = parts[0]
		var args = parts[1].split(")", true, 2)[0]
		var pArgArray = args.split(",", true)
		var argArray = cleanArgs(pArgArray)	
		if $Player._actions.has(action) && actions.has(action):
			var act = actions[action]
			if validParameters(argArray, act.argCount):
				act.funcRef.call_func(argArray)
			else:
				$InputTerminal/TextField.text = "Invalid parameters"
		else:
			$InputTerminal/TextField.text = $Player._name + " can't do that"
	else:
		$InputTerminal/TextField.text = "Invalid declaration"

func cleanArgs(argArray: PoolStringArray):
	var args = []
	for arg in argArray:
		if arg != "":
			args.append(arg)	
	for i in range(0, args.size()):
		args[i] = args[i].replace("\"", "")
	return args

func validParameters(argArray, expectedCount: int):
	return argArray.size() == expectedCount

func populatePossibleActions():
	populateAction("print", "_print", 1)
	populateAction("move", "_move", 2)
	populateAction("take", "_take", 0)
	populateAction("use", "_use", 0)
	populateAction("help", "_help", 0)

func populateAction(alias, funcName, argCount):
	var funcRef = funcref($Player, funcName)
	actions[alias] = Action.new(funcRef, argCount)