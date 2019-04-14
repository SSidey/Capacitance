extends Node

class_name Action

var funcRef: FuncRef
var argCount: int

func _init(funcRef, argCount):
	self.funcRef = funcRef
	self.argCount = argCount