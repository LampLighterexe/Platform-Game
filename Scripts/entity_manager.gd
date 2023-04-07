extends Node

var EntityDict = {}

func addEntity(e):
	EntityDict[e.name] = e

func getEntity(e):
	if isEntityVaild(e): return EntityDict[e]
	if isEntityNameVaild(e): return EntityDict["_"+e]
	push_error(e," was not found in entity manager! returning null")
	return null
		
func isEntityVaild(e):
	if e in EntityDict and not EntityDict[e] == null:
		return true
func isEntityNameVaild(e):
	if "_"+e in EntityDict and not EntityDict["_"+e] == null:
		return true
func cleanRefs():
	var newDict = {}
	for key in EntityDict:
		if not EntityDict[key] == null:
			newDict[key] = EntityDict[key]
	EntityDict = newDict

