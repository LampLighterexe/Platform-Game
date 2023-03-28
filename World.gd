extends Node
#@onready var player = $Player


@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $HUD
@onready var health_bar = $HUD/SubViewportContainer/SubViewport/HealthBarBackground

@onready var muliplayerspawner = $MultiplayerSpawner

func _ready():
	muliplayerspawner.spawn_function = test

func test(e):
	var obj = Enemy.instantiate()
	obj.name = "_"+str(get_tree().get_nodes_in_group("enemies").size())
	EntityManager.addEntity(obj)
	return obj

const Player = preload("res://player.tscn")
const Enemy = preload("res://Enemy.tscn")
const PORT = 32030
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debugkey1"):
		#var newobj = Enemy.instantiate()
		#newobj.position = Vector3(0,2,0)
		muliplayerspawner.spawn(Enemy)
		
		#add_child(newobj)

func _physics_process(delta):
	#if player.global_transform.origin.y < -25:
	#	player.global_transform.origin.y += 50
	#	player.velocity.y = 0
	
	#if is_multiplayer_authority():
	var enemytarget = get_tree().get_nodes_in_group("player")
	#print(enemytarget)
	if enemytarget.size() > 0:
		get_tree().call_group("enemies","update_target_location", enemytarget[0].global_transform.origin)

#Work in progress connecting moster death to gain points
#I got it -Matthew
#func _enemyDeath():
#	enemy.isALive.connect()

	
func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	if not address_entry.text == "localhost":
		upnp_setup()

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
	EntityManager.addEntity(player)
	
	if player.is_multiplayer_authority():
		player.HealthChanged.connect(update_health_barb)


func update_health_barb(h,mh):
	health_bar.update_health_bar(h,mh)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.HealthChanged.connect(update_health_barb)

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
