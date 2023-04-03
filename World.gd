extends Node
#@onready var player = $Player

var MemCleanTimer = 0
var RequiresReset = false

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $HUD
@onready var health_bar = $HUD/SubViewportContainer/SubViewport/HealthBarBackground
@onready var muliplayerspawner = $MultiplayerSpawner
@onready var upnp_button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/UPnP
@onready var CharacterSelect = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/HBoxContainer/OptionButton

func _ready():
	muliplayerspawner.spawn_function = spawnEnemy
	for i in Registry.PlayerFact.PlayerDict:
		CharacterSelect.add_item(i,CharacterSelect.item_count)

func spawnEnemy(e):
	var obj = Enemy.instantiate()
	obj.name = e["id"]+"_"+str(get_tree().get_nodes_in_group("enemies").size())
	EntityManager.addEntity(obj)
	return obj

const Player = preload("res://player.tscn")
const Enemy = preload("res://Enemy.tscn")
var PORT = 32030
var mode = "UPnP"
var enet_peer = ENetMultiplayerPeer.new()

var Server = null

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debugkey1"):
		#if this somehow creates a use after free i'm going to just quit

		muliplayerspawner.spawn({"id":str(randi_range(-65535,65534)),"type":"spider"})

func _physics_process(delta):
	if is_multiplayer_authority():
		var enemytarget = get_tree().get_nodes_in_group("player")
		get_tree().call_group("enemies","update_target_list",enemytarget)
	
	MemCleanTimer += delta
	if MemCleanTimer > 10:
		EntityManager.cleanRefs()
		MemCleanTimer = 0


#Work in progress connecting moster death to gain points
#I got it -Matthew
#func _enemyDeath():
#	enemy.isALive.connect()


func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	var address = address_entry.text.split(":")
	if address.size() > 1:
		PORT = int(address[-1])

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

	if upnp_button.button_pressed:
		upnp_setup()

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	var address = address_entry.text.split(":")
	if address.size() > 1:
		PORT = int(address[-1])
	print(address[0],":", PORT)
	enet_peer.create_client(address[0], PORT)
	multiplayer.multiplayer_peer = enet_peer
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	
	#player.character = CharacterSelect.get_item_text(CharacterSelect.get_selected_id())
	add_child(player)
	EntityManager.addEntity(player)
	
	if player.is_multiplayer_authority():
		player.HealthChanged.connect(update_health_bar)
	RequiresReset = true


func update_health_bar(h,mh):
	health_bar.update_health_bar(h,mh)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_multiplayer_spawner_spawned(node):
	RequiresReset = true
	if node.is_multiplayer_authority():
		node.HealthChanged.connect(update_health_bar)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
