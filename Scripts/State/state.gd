class_name State extends Node

signal transitioned(fromState:State, toStateName:String)

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass

func unhandled_input(event: InputEvent) -> void:
	pass

func transitionToState(stateName:String) -> void:
	transitioned.emit(self, stateName)
