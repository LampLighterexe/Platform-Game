extends Node

class_name PlayerRegistry

var PlayerDict = {}

func _init():
	register("default",PlayerConfig.new({
		"PlayerModel":preload("res://Characters/Guy.tscn")
	}))
	register("dolphin",PlayerConfig.new({
		"MaxHealth":200.0,
	}))
	register("soundbyte",PlayerConfig.new({
		"MaxHealth":200.0,
		"PlayerModel":preload("res://Characters/soundbyte.tscn"),
		"ViewHeight":1.42,
		"Size":1.5,
		"KbMul":0.5
	}))
	register("base",PlayerConfig.new({
		"PlayerModel":preload("res://Characters/base.tscn"),
		"ViewHeight":1.4,
		"KbMul":3,
	}))

func register(playername, playerconfig):
	PlayerDict[playername] = playerconfig
	
func getPlayer(playername):
	if playername in PlayerDict:
		return PlayerDict[playername]
	push_warning("Could not find ",playername," in registry!")
	return PlayerDict["default"]

func setPlayer(obj,playername):
	obj.setVals(getPlayer(playername).SetVars)
