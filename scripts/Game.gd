extends Node2D

var current_character: CharacterBody2D
var selected_character_type: String = ""
var peer = ENetMultiplayerPeer.new()
@onready var players: Node = $Players

# --- 角色脚本里需要添加的变量 ---
# 为了让后加入的玩家能看到老玩家，你需要在你的角色脚本 (Knight.gd, Archer.gd 等)
# 的顶部添加一行:
#
# var character_type: String = ""
#
# 这样我们才能知道每个已存在角色的类型。

func _ready():
	# Connect back button
	$UI/BackButton.pressed.connect(_on_back_button_pressed)
	
	# Connect language change signal
	LanguageManager.language_changed.connect(_update_ui_text)
	
	# Connect Global signals
	Global.character_selected.connect(_on_character_selected)
	Global.game_state_changed.connect(_on_game_state_changed)
	
	# --- 多人信号连接 ---
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	_update_ui_text()
	Global.change_game_state(Global.GameState.PLAYING)
	_add_test_controls()

# ... (你其他的非多人游戏函数如 _add_test_controls, _test_damage 等保持不变) ...

func _add_test_controls():
	var test_panel = Panel.new()
	test_panel.name = "TestPanel"
	test_panel.position = Vector2(10, 10)
	test_panel.size = Vector2(200, 100)
	var vbox = VBoxContainer.new()
	test_panel.add_child(vbox)
	var damage_button = Button.new()
	damage_button.text = "Test Damage (20)"
	damage_button.pressed.connect(_test_damage)
	vbox.add_child(damage_button)
	var death_button = Button.new()
	death_button.text = "Test Death (100)"
	death_button.pressed.connect(_test_death)
	vbox.add_child(death_button)
	var heal_button = Button.new()
	heal_button.text = "Heal (50)"
	heal_button.pressed.connect(_test_heal)
	vbox.add_child(heal_button)
	add_child(test_panel)

func _test_damage():
	if current_character and current_character.has_method("take_damage"):
		current_character.take_damage(20)

func _test_death():
	if current_character and current_character.has_method("take_damage"):
		current_character.take_damage(100)

func _test_heal():
	if current_character and current_character.has_method("heal"):
		current_character.heal(50)

func spawn_character(character_type: String):
	# 这个函数现在只用于单机测试，多人游戏不使用它
	pass

func _process(delta):
	# UI更新等逻辑保持不变
	pass

func _update_ui():
	pass

func _update_ui_text():
	$UI/CharacterInfo/ControlsLabel.text = LanguageManager.get_text("controls")
	$UI/CharacterInfo/MovementLabel.text = LanguageManager.get_text("move")
	$UI/CharacterInfo/AttackLabel.text = LanguageManager.get_text("jump")
	$UI/CharacterInfo/MouseAttack1Label.text = LanguageManager.get_text("attack1")
	$UI/CharacterInfo/MouseAttack2Label.text = LanguageManager.get_text("attack2")
	$UI/CharacterInfo/Skill1Label.text = LanguageManager.get_text("skill1")
	$UI/CharacterInfo/Skill2Label.text = LanguageManager.get_text("skill2")
	$UI/BackButton.text = LanguageManager.get_text("back_to_menu")

func _on_character_selected(character_name: String):
	pass

func _on_game_state_changed(new_state: Global.GameState):
	pass

func _on_back_button_pressed():
	Global.reset_selections()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _input(event):
	pass

# ----------------------------------------------------------------
# --- 已修复的多人游戏逻辑 ---
# ----------------------------------------------------------------

# 1. [核心RPC函数] 这个函数会在所有玩家的电脑上运行，用于生成角色。
@rpc("any_peer", "call_local", "reliable")
func spawn_player_for_everyone(id: int, character_type: String):
	# 避免重复生成
	if players.has_node(str(id)):
		return

	var character_path = "res://characters/" + character_type + ".tscn"
	var character_scene = load(character_path)

	if character_scene:
		var player_instance = character_scene.instantiate()
		player_instance.name = str(id)
		# 关键: 我们需要给角色实例一个变量来存储它的类型，以便后加入的玩家同步
		player_instance.character_type = character_type
		
		players.add_child(player_instance)
		player_instance.set_multiplayer_authority(id) # 把控制权交给对应的玩家
		print("在玩家 %s 的电脑上为ID %s 生成了角色 %s" % [multiplayer.get_unique_id(), id, character_type])
	else:
		print("错误: 无法加载场景路径: " + character_path)

# 2. [服务器函数] 这个函数由客户端调用，用于请求生成角色。
@rpc("any_peer")
func server_request_spawn(character_to_spawn: String):
	# 这个函数只应该在服务器上执行
	if not multiplayer.is_server():
		return
		
	# 获取是谁发送的这个请求
	var new_player_id = multiplayer.get_remote_sender_id()
	print("服务器: 收到来自玩家 %s 的生成请求, 角色为 %s" % [new_player_id, character_to_spawn])
	
	# 命令所有人（包括新玩家自己）去生成这个新玩家的角色
	spawn_player_for_everyone.rpc(new_player_id, character_to_spawn)

# --- 信号处理器 ---

# 3. [主机] 当“创建”按钮被按下时
func _on_create_button_down() -> void:
	var error = peer.create_server(25565)
	if error != OK:
		return
	multiplayer.multiplayer_peer = peer
	
	# 主机也必须通过RPC来为自己生成角色，这样才能保证逻辑统一
	spawn_player_for_everyone.rpc(multiplayer.get_unique_id(), Global.selected_character)

# 4. [客户端] 当“加入”按钮被按下时
func _on_join_button_down() -> void:
	peer.create_client("127.0.0.1", 25565)
	multiplayer.multiplayer_peer = peer
	# 后续逻辑在 _on_connected_to_server 中处理

# 5. [客户端] 当成功连接到服务器时
func _on_connected_to_server():
	print("客户端: 成功连接到服务器。")
	# 告诉服务器我准备好了，以及我想要的角色是什么
	server_request_spawn.rpc_id(1, Global.selected_character)

# 6. [同步逻辑] 当有新玩家连接时
func _on_peer_connected(id: int) -> void:
	print("通知: 玩家 %s 已连接。" % [id])
	
	# 只有服务器需要负责同步，客户端忽略
	if not multiplayer.is_server():
		return
		
	# 遍历所有已经存在的玩家
	for child in players.get_children():
		var existing_player_id = int(child.name)
		
		# 不需要告诉新玩家生成他自己
		if existing_player_id == id:
			continue
		
		# 获取老玩家的角色类型 (这依赖于你在角色脚本中添加的 character_type 变量)
		var existing_character_type = child.character_type
		
		# 单独向新加入的玩家(id)发送RPC，命令他去生成一个老玩家(existing_player_id)的角色
		spawn_player_for_everyone.rpc_id(id, existing_player_id, existing_character_type)
