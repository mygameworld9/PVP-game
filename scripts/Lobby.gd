extends Control

signal player_joined(id)
signal player_left(id)

var is_host := false
var peer : ENetMultiplayerPeer
var players := []

func _ready():
	$VBox/HostBtn.pressed.connect(_on_host_pressed)
	$VBox/JoinBtn.pressed.connect(_on_join_pressed)
	$VBox/LeaveBtn.pressed.connect(_on_leave_pressed)
	player_joined.connect(_update_player_list)
	player_left.connect(_update_player_list)
	_update_player_list()

func host_lobby(port := 12345, max_clients := 8):
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, max_clients)
	if result != OK:
		push_error("Failed to start server: %s" % result)
		return false
	get_tree().get_multiplayer().multiplayer_peer = peer
	is_host = true
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(_on_peer_disconnected)
	players.append(get_tree().get_multiplayer().get_unique_id())
	player_joined.emit(get_tree().get_multiplayer().get_unique_id())
	return true

func join_lobby(ip: String, port := 12345):
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	if result != OK:
		push_error("Failed to connect to server: %s" % result)
		return false
	get_tree().get_multiplayer().multiplayer_peer = peer
	is_host = false
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(_on_peer_disconnected)
	return true

func _on_peer_connected(id):
	if id not in players:
		players.append(id)
	player_joined.emit(id)

func _on_peer_disconnected(id):
	if id in players:
		players.erase(id)
	player_left.emit(id)

func leave_lobby():
	if peer:
		peer.close()
	get_tree().get_multiplayer().multiplayer_peer = null
	players.clear()
	is_host = false 

func _on_host_pressed():
	host_lobby()
	_update_player_list()

func _on_join_pressed():
	# For demo, join localhost. In production, prompt for IP.
	join_lobby("127.0.0.1")
	_update_player_list()

func _on_leave_pressed():
	leave_lobby()
	_update_player_list()

func _update_player_list(_id := null):
	var list = $VBox/PlayerList
	list.clear()
	for id in players:
		list.add_item("Player %s" % str(id)) 