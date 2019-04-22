extends Node

class_name UserAction

var funcName: String
var args = []
var argCount = 0
var funcLines = []

func _init(funcName, args, funcLines):
	self.funcName = funcName
	self.args = args
	self.argCount = args.size()
	self.funcLines = funcLines
