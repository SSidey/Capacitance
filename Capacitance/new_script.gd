extends Node

class_name UserAction

var funcName: String
var args = []
var argCount: int
var funcLines = []

func _init(funcName, argCount, args, funcLines):
	self.funcName = funcName
	self.args = args
	self.argCount = args.count()
	self.funcLines = funcLines
