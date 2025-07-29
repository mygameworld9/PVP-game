extends Node2D

# TileMap层绘制工具
# 使用TileMap的多个层来绘制地图

var current_tilemap: TileMap
var current_layer: int = 0
var current_tile_id: int = 0
var is_drawing: bool = false

# 层配置
var layers = {
	0: {"name": "Ground", "description": "地面层"},
	1: {"name": "Decoration", "description": "装饰层"},
	2: {"name": "Obstacles", "description": "障碍层"},
	3: {"name": "Background", "description": "背景层"}
}

# UI元素
@onready var layer_buttons: HBoxContainer = $UIPanel/VBoxContainer/LayerButtons
@onready var tile_buttons: HBoxContainer = $UIPanel/VBoxContainer/TileButtons
@onready var status_label: Label = $UIPanel/VBoxContainer/StatusLabel
@onready var layer_info: Label = $UIPanel/VBoxContainer/LayerInfo
@onready var toggle_button: Button = $UIPanel/VBoxContainer/ButtonContainer/ToggleButton
@onready var clear_layer_button: Button = $UIPanel/VBoxContainer/ButtonContainer/ClearLayerButton
@onready var clear_all_button: Button = $UIPanel/VBoxContainer/ButtonContainer/ClearAllButton
@onready var save_button: Button = $UIPanel/VBoxContainer/ButtonContainer/SaveButton
@onready var load_button: Button = $UIPanel/VBoxContainer/ButtonContainer/LoadButton

func _ready():
	_setup_ui()
	_setup_tilemap_layers()

func _setup_ui():
	# 创建层选择按钮
	_create_layer_buttons()
	
	# 创建瓦片选择按钮
	_create_tile_buttons()
	
	# 设置状态标签
	status_label.text = "选择层和瓦片类型，然后点击地图绘制"
	_update_layer_info()
	
	# 连接按钮信号
	toggle_button.pressed.connect(toggle_drawing)
	clear_layer_button.pressed.connect(clear_current_layer)
	clear_all_button.pressed.connect(clear_all_layers)
	save_button.pressed.connect(save_map_layers)
	load_button.pressed.connect(load_map_layers)

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

func _setup_tilemap_layers():
	# 获取或创建TileMap
	current_tilemap = get_node_or_null("Mainground")
	if not current_tilemap:
		current_tilemap = TileMap.new()
		current_tilemap.name = "Mainground"
		add_child(current_tilemap)
		
		# 加载TileSet
		var tileset = load("res://tilesets/ForestMap.tres")
		if tileset:
			current_tilemap.tile_set = tileset
		
		# 创建基础地面层
		_create_basic_ground_layer()

func _create_basic_ground_layer():
	# 在层0创建基础地面瓦片
	for x in range(20):
		for y in range(15):
			current_tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

func _input(event):
	if not is_drawing:
		return
	
	# 鼠标点击绘制瓦片
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_draw_tile_at_mouse_position()

func _draw_tile_at_mouse_position():
	# 获取鼠标位置并转换为瓦片坐标
	var mouse_pos = get_global_mouse_position()
	var tile_pos = current_tilemap.local_to_map(mouse_pos)
	
	# 在当前层绘制瓦片
	current_tilemap.set_cell(current_layer, tile_pos, 0, Vector2i(current_tile_id, 0))
	
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
		status_label.text = "绘制模式已启用 - 点击地图绘制瓦片"
	else:
		status_label.text = "绘制模式已禁用"

func clear_current_layer():
	# 清除当前层的所有瓦片
	for x in range(20):
		for y in range(15):
			current_tilemap.set_cell(current_layer, Vector2i(x, y), -1)
	
	status_label.text = "已清除层 " + str(current_layer) + ": " + layers[current_layer]["name"]

func clear_all_layers():
	# 清除所有层的瓦片
	for layer in layers.keys():
		for x in range(20):
			for y in range(15):
				current_tilemap.set_cell(layer, Vector2i(x, y), -1)
	
	status_label.text = "已清除所有层"

func save_map_layers():
	# 保存所有层的地图数据
	var map_data = _get_all_layers_data()
	var file = FileAccess.open("user://layered_map.dat", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(map_data))
		file.close()
		status_label.text = "多层地图已保存!"

func _get_all_layers_data() -> Dictionary:
	# 获取所有层的地图数据
	var map_data = {
		"width": 20,
		"height": 15,
		"layers": {}
	}
	
	for layer_id in layers.keys():
		map_data["layers"][str(layer_id)] = {
			"name": layers[layer_id]["name"],
			"tiles": {}
		}
		
		for x in range(20):
			for y in range(15):
				var cell_data = current_tilemap.get_cell_source_id(layer_id, Vector2i(x, y))
				if cell_data != -1:
					map_data["layers"][str(layer_id)]["tiles"][str(x) + "," + str(y)] = cell_data
	
	return map_data

func load_map_layers():
	# 加载多层地图数据
	var file = FileAccess.open("user://layered_map.dat", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var map_data = json.data
			_load_all_layers_data(map_data)
			status_label.text = "多层地图已加载!"

func _load_all_layers_data(map_data: Dictionary):
	# 加载所有层的地图数据
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
			
			current_tilemap.set_cell(layer_id, Vector2i(x, y), 0, Vector2i(tile_id, 0)) 