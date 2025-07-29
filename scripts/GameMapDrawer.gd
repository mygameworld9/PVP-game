extends Node2D

# 游戏场景中的地图绘制器
# 允许在游戏场景中直接绘制地图

var tilemap: TileMap
var current_layer: int = 0
var current_tile_id: int = 0
var is_drawing: bool = false
var is_draw_mode: bool = false

# 层配置
var layers = {
	0: {"name": "Ground", "description": "地面层", "color": Color.WHITE},
	1: {"name": "Decoration", "description": "装饰层", "color": Color.YELLOW},
	2: {"name": "Obstacles", "description": "障碍层", "color": Color.RED},
	3: {"name": "Background", "description": "背景层", "color": Color.BLUE}
}

# UI元素
@onready var draw_panel: Panel = $DrawPanel
@onready var layer_buttons: HBoxContainer = $DrawPanel/VBoxContainer/LayerButtons
@onready var tile_buttons: HBoxContainer = $DrawPanel/VBoxContainer/TileButtons
@onready var status_label: Label = $DrawPanel/VBoxContainer/StatusLabel
@onready var layer_info: Label = $DrawPanel/VBoxContainer/LayerInfo

func _ready():
	_setup_ui()
	_setup_tilemap()
	# 默认隐藏绘制面板
	draw_panel.visible = false

func _setup_ui():
	# 创建层选择按钮
	_create_layer_buttons()
	
	# 创建瓦片选择按钮
	_create_tile_buttons()
	
	# 设置状态标签
	status_label.text = "按F1切换绘制模式，选择层和瓦片类型，然后点击地图绘制"
	_update_layer_info()
	
	# 连接按钮信号
	$DrawPanel/VBoxContainer/ButtonContainer/ToggleButton.pressed.connect(toggle_drawing)
	$DrawPanel/VBoxContainer/ButtonContainer/ClearLayerButton.pressed.connect(clear_current_layer)
	$DrawPanel/VBoxContainer/ButtonContainer/ClearAllButton.pressed.connect(clear_all_layers)
	$DrawPanel/VBoxContainer/ButtonContainer/SaveButton.pressed.connect(save_map)
	$DrawPanel/VBoxContainer/ButtonContainer/LoadButton.pressed.connect(load_map)

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
	# 获取或创建TileMap
	tilemap = get_node_or_null("Mainground")
	if not tilemap:
		tilemap = TileMap.new()
		tilemap.name = "Mainground"
		add_child(tilemap)
		
		# 加载TileSet
		var tileset = load("res://tilesets/ForestMap.tres")
		if tileset:
			tilemap.tile_set = tileset
		
		# 创建基础地面层
		_create_basic_ground_layer()

func _create_basic_ground_layer():
	# 在层0创建基础地面瓦片
	for x in range(20):
		for y in range(15):
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))

func _input(event):
	# 按F1切换绘制模式
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			toggle_draw_mode()
	
	# 绘制模式下的鼠标输入
	if is_draw_mode and is_drawing:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_draw_tile_at_mouse_position()

func toggle_draw_mode():
	is_draw_mode = !is_draw_mode
	draw_panel.visible = is_draw_mode
	
	if is_draw_mode:
		status_label.text = "绘制模式已启用 - 选择层和瓦片类型，然后点击地图绘制"
	else:
		status_label.text = "绘制模式已禁用 - 按F1重新启用"

func _draw_tile_at_mouse_position():
	# 获取鼠标位置并转换为瓦片坐标
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tilemap.local_to_map(mouse_pos)
	
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
	for x in range(20):
		for y in range(15):
			tilemap.set_cell(current_layer, Vector2i(x, y), -1)
	
	status_label.text = "已清除层 " + str(current_layer) + ": " + layers[current_layer]["name"]

func clear_all_layers():
	# 清除所有层的瓦片
	for layer in layers.keys():
		for x in range(20):
			for y in range(15):
				tilemap.set_cell(layer, Vector2i(x, y), -1)
	
	status_label.text = "已清除所有层"

func save_map():
	# 保存地图数据
	var map_data = _get_map_data()
	var file = FileAccess.open("user://game_map.dat", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(map_data))
		file.close()
		status_label.text = "地图已保存!"

func load_map():
	# 加载地图数据
	var file = FileAccess.open("user://game_map.dat", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var map_data = json.data
			_load_map_data(map_data)
			status_label.text = "地图已加载!"

func _get_map_data() -> Dictionary:
	# 获取地图数据
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