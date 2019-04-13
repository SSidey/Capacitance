extends Node2D

var actions = {}

func _ready():
	populatePossibleActions()

func _handle_input():
	var text = $InputTerminal/TextField.text
	var split = text.split(".", true, 2)
	if split[0] == $Player._name:
		handleFunction(split[1])

func handleFunction(function):
	var parts = function.split("(", true, 2)
	var action = parts[0]
	var args = parts[1].split(")", true, 2)[0]
	var argArray = args.split(",", true)
	if $Player._actions.has(action):
		if actions.has(action):
			var act = actions[action]
			act.call_func(argArray)

func populatePossibleActions():
	populateAction("print", "_print")
	populateAction("move", "_move")

func populateAction(alias, funcName):
	var funcRef = funcref($Player, funcName)
	actions[alias] = funcRef