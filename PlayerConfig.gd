extends CharacterBody3D

class_name PlayerConfig

var airSpeed = 0.2
var speed = 1.0
var jumpVelocity = 6
var airDecel = 0.30
var groundDecel = 0.0001
var gravity = 9.8
var MaxHealth = 100.0
var PlayerModel = null
var Size = 1.0
var ViewHeight = null
var SetVars = {}

func _init(dict={}):
	for entry in dict:
		self[entry] = dict[entry]
	SetVars = dict

func setVals(dict={}):
	for entry in dict:
		self[entry] = dict[entry]
	#SetVars = dict
	#if "ModelScene" in dict and dict["ModelScene"]:
	#	self.ModelScene = load(dict["Model"])
