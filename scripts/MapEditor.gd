extends Control

# 独立的地图编辑器
# 用于在游戏外设计地图

var tilemap: TileMap
var current_layer: int = 0
var current_tile_id: int = 0
var is_drawing: bool = false
var map_size: Vector2i = Vector2i(50, 30)  # 更大的地图尺寸

# 层配置
var layers = {
	0: {"name": "Ground", "description": "地面层", "color": Color.WHITE},
	1: {"name": "Decoration", "description": "装饰层", "color": Color.YELLOW},
	2: {"name": "Obstacles", "description": "障碍层", "color": Color.RED},
	3: {"name": "Background", "description": "背景层", "color": Color.BLUE}
}

# UI元素
@onready var tilemap_container: Node2D = $TileMapContainer
@onready var layer_buttons: HBoxContainer = $UIPanel/VBoxContainer/LayerButtons
@onready var tile_buttons: HBoxContainer = $UIPanel/VBoxContainer/TileButtons
@onready var status_label: Label = $UIPanel/VBoxContainer/StatusLabel
@onready var layer_info: Label = $UIPanel/VBoxContainer/LayerInfo
@onready var map_name_input: LineEdit = $UIPanel/VBoxContainer/MapNameInput

func _ready():
	_setup_ui()
	_setup_tilemap()
	_setup_camera()

func _setup_ui():
	# 创建层选择按钮
	_create_layer_buttons()
	
	# 创建瓦片选择按钮
	_create_tile_buttons()
	
	# 设置状态标签
	status_label.text = "选择层和瓦片类型，然后点击地图绘制"
	_update_layer_info()
	
	# 连接按钮信号
	$UIPanel/VBoxContainer/ButtonContainer/ToggleButton.pressed.connect(toggle_drawing)
	$UIPanel/VBoxContainer/ButtonContainer/ClearLayerButton.pressed.connect(clear_current_layer)
	$UIPanel/VBoxContainer/ButtonContainer/ClearAllButton.pressed.connect(clear_all_layers)
	$UIPanel/VBoxContainer/ButtonContainer/SaveButton.pressed.connect(save_map)
	$UIPanel/VBoxContainer/ButtonContainer/LoadButton.pressed.connect(load_map)
	$UIPanel/VBoxContainer/ButtonContainer/BackButton.pressed.connect(_on_back_button_pressed)

func _create_layer_buttons():
	# 创建不同层的按钮
	for layer_id in layers.keys():
		var button = Button.new()
		button.text = layers[layer_id]["name"]
		button.custom_minimum_size = Vector2(80, 30)
		button.pressed.connect(_on_layer_button_pressed.bind(layer_id))
		layer_buttons.add_child(button)

func _create_tile_buttons():
	# 创建不同瓦片的按钮
	var tile_ids = [0, 1, 2, 3, 4, 5, 6]  # 可用的瓦片ID
	
	for tile_id in tile_ids:
		var button = Button.new()
		button.text = "瓦片 " + str(tile_id)
		button.custom_minimum_size = Vector2(50, 30)
		button.pressed.connect(_on_tile_button_pressed.bind(tile_id))
		tile_buttons.add_child(button)

func _setup_tilemap():
	# 创建TileMap
	tilemap = TileMap.new()
	tilemap.name = "MapEditorTileMap"
	tilemap_container.add_child(tilemap)
	
	# 加载TileSet
	var tileset = load("res://tilesets/ForestMap.tres")
	if tileset:
		tilemap.tile_set = tileset
	
	# 创建基础地面层
	_create_basic_ground_layer()

func _setup_camera():
	# 添加相机用于地图导航
	var camera = Camera2D.new()
	camera.name = "MapEditorCamera"
	camera.enabled = true
	tilemap_container.add_child(camera)
	
	# 设置相机初始位置
	camera.global_position = Vector2(map_size.x * 16 / 2, map_size.y * 16 / 2)

func _create_basic_ground_layer():
	# 在层0创建基础地面瓦片
	for x in range(map_size.x):
		for y in range(map_size.y):
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

func _input(event):
	# 相机控制
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			var camera = tilemap_container.get_node("MapEditorCamera")
			camera.global_position -= event.relative
	
	# 缩放控制
	if event is InputEventMouseButton and event.pressed:
		var camera = tilemap_container.get_node("MapEditorCamera")
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 0.9
	
	# 绘制模式下的鼠标输入
	if is_drawing:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_draw_tile_at_mouse_position()

func _draw_tile_at_mouse_position():
	# 获取鼠标位置并转换为瓦片坐标
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tilemap.local_to_map(tilemap.to_local(mouse_pos))
	
	# 检查边界
	if tile_pos.x >= 0 and tile_pos.x < map_size.x and tile_pos.y >= 0 and tile_pos.y < map_size.y:
		# 在当前层绘制瓦片
		tilemap.set_cell(current_layer, tile_pos, 0, Vector2i(current_tile_id, 0))
		
		# 更新状态
		status_label.text = "在层 " + str(current_layer) + " 位置 " + str(tile_pos) + " 绘制了瓦片 " + str(current_tile_id)

func _on_layer_button_pressed(layer_id: int):
	current_layer = layer_id
	_update_layer_info()
	status_label.text = "选择了层: " + layers[layer_id]["name"]

func _on_tile_button_pressed(tile_id: int):
	current_tile_id = tile_id
	status_label.text = "选择了瓦片 " + str(tile_id) + "，点击地图绘制"

func _update_layer_info():
	var layer_name = layers[current_layer]["name"]
	var layer_desc = layers[current_layer]["description"]
	layer_info.text = "当前层: " + layer_name + " (" + layer_desc + ")"

func toggle_drawing():
	is_drawing = !is_drawing
	if is_drawing:
		status_label.text = "绘制已启用 - 点击地图绘制瓦片"
	else:
		status_label.text = "绘制已禁用"

func clear_current_layer():
	# 清除当前层的所有瓦片
	for x in range(map_size.x):
		for y in range(map_size.y):
			tilemap.set_cell(current_layer, Vector2i(x, y), -1)
	
	status_label.text = "已清除层 " + str(current_layer) + ": " + layers[current_layer]["name"]

func clear_all_layers():
	# 清除所有层的瓦片
	for layer in layers.keys():
		for x in range(map_size.x):
			for y in range(map_size.y):
				tilemap.set_cell(layer, Vector2i(x, y), -1)
	
	status_label.text = "已清除所有层"

func save_map():
	var map_name = map_name_input.text
	if map_name.is_empty():
		map_name = "CustomMap"
	
	# 保存地图数据
	var map_data = _get_map_data(map_name)
	var file = FileAccess.open("user://" + map_name + ".dat", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(map_data))
		file.close()
		status_label.text = "地图已保存为: " + map_name + ".dat"

func load_map():
	var map_name = map_name_input.text
	if map_name.is_empty():
		map_name = "CustomMap"
	
	# 加载地图数据
	var file = FileAccess.open("user://" + map_name + ".dat", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var map_data = json.data
			_load_map_data(map_data)
			status_label.text = "地图已加载: " + map_name + ".dat"
	else:
		status_label.text = "找不到地图文件: " + map_name + ".dat"

func _get_map_data(map_name: String) -> Dictionary:
	# 获取地图数据
	var map_data = {
		"name": map_name,
		"width": map_size.x,
		"height": map_size.y,
		"layers": {}
	}
	
	for layer_id in layers.keys():
		map_data["layers"][str(layer_id)] = {
			"name": layers[layer_id]["name"],
			"tiles": {}
		}
		
		for x in range(map_size.x):
			for y in range(map_size.y):
				var cell_data = tilemap.get_cell_source_id(layer_id, Vector2i(x, y))
				if cell_data != -1:
					map_data["layers"][str(layer_id)]["tiles"][str(x) + "," + str(y)] = cell_data
	
	return map_data

func _load_map_data(map_data: Dictionary):
	# 加载地图数据
	clear_all_layers()
	
	var layers_data = map_data.get("layers", {})
	for layer_key in layers_data:
		var layer_id = int(layer_key)
		var layer_data = layers_data[layer_key]
		var tiles = layer_data.get("tiles", {})
		
		for tile_key in tiles:
			var coords = tile_key.split(",")
			var x = int(coords[0])
			var y = int(coords[1])
			var tile_id = tiles[tile_key]
			
			tilemap.set_cell(layer_id, Vector2i(x, y), 0, Vector2i(tile_id, 0))

func _on_back_button_pressed():
	# 返回主菜单
	get_tree().change_scene_to_file("res://scenes/Main.tscn") 