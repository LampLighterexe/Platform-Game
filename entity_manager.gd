extends Node

var EntityDict = {}

func addEntity(e):
	EntityDict[e.name] = e

func getEntity(e):
	if isEntityVaild(e): return EntityDict[e]
	if isEntityNameVaild(e): return EntityDict["_"+e]
		
func isEntityVaild(e):
	if e in EntityDict:
		return true
func isEntityNameVaild(e):
	if "_"+e in EntityDict:
		return true
func cleanRefs():
	var newDict = {}
	for key in EntityDict:
		if not EntityDict[key] == null:
			newDict[key] = EntityDict[key]
	EntityDict = newDict

