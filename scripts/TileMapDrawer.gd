extends Node2D

# 简单的TileMap绘制工具
# 允许用户直接在TileMap上绘制瓦片

var current_tilemap: TileMap
var current_tile_id: int = 0
var is_drawing: bool = false

# UI元素
@onready var tile_buttons: HBoxContainer = $UIPanel/VBoxContainer/TileButtons
@onready var status_label: Label = $UIPanel/VBoxContainer/StatusLabel
@onready var toggle_button: Button = $UIPanel/VBoxContainer/ButtonContainer/ToggleButton
@onready var clear_button: Button = $UIPanel/VBoxContainer/ButtonContainer/ClearButton
@onready var save_button: Button = $UIPanel/VBoxContainer/ButtonContainer/SaveButton

func _ready():
	_setup_ui()
	_setup_tilemap()

func _setup_ui():
	# 创建瓦片选择按钮
	_create_tile_buttons()
	
	# 设置状态标签
	status_label.text = "选择瓦片类型，然后点击地图绘制"
	
	# 连接按钮信号
	toggle_button.pressed.connect(toggle_drawing)
	clear_button.pressed.connect(clear_map)
	save_button.pressed.connect(save_map)

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
	current_tilemap = get_node_or_null("Mainground")
	if not current_tilemap:
		current_tilemap = TileMap.new()
		current_tilemap.name = "Mainground"
		add_child(current_tilemap)
		
		# 加载TileSet
		var tileset = load("res://tilesets/ForestMap.tres")
		if tileset:
			current_tilemap.tile_set = tileset
		
		# 创建基础地面
		_create_basic_ground()

func _create_basic_ground():
	# 创建基础地面瓦片
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
	
	# 绘制当前选择的瓦片
	current_tilemap.set_cell(0, tile_pos, 0, Vector2i(current_tile_id, 0))
	
	# 更新状态
	status_label.text = "在位置 " + str(tile_pos) + " 绘制了瓦片 " + str(current_tile_id)

func _on_tile_button_pressed(tile_id: int):
	current_tile_id = tile_id
	status_label.text = "选择了瓦片 " + str(tile_id) + "，点击地图绘制"

func toggle_drawing():
	is_drawing = !is_drawing
	if is_drawing:
		status_label.text = "绘制模式已启用 - 点击地图绘制瓦片"
	else:
		status_label.text = "绘制模式已禁用"

func clear_map():
	# 清除所有瓦片
	for x in range(20):
		for y in range(15):
			current_tilemap.set_cell(0, Vector2i(x, y), -1)
	
	status_label.text = "地图已清除"

func save_map():
	# 保存地图数据到文件
	var map_data = _get_map_data()
	var file = FileAccess.open("user://custom_map.dat", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(map_data))
		file.close()
		status_label.text = "地图已保存!"

func _get_map_data() -> Dictionary:
	# 获取当前地图数据
	var map_data = {
		"width": 20,
		"height": 15,
		"tiles": {}
	}
	
	for x in range(20):
		for y in range(15):
			var cell_data = current_tilemap.get_cell_source_id(0, Vector2i(x, y))
			if cell_data != -1:
				map_data["tiles"][str(x) + "," + str(y)] = cell_data
	
	return map_data 