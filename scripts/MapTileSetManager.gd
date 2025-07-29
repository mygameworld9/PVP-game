extends Node

# Map TileSet Manager - 管理不同地图的TileSet

# TileSet资源字典
var tileset_resources: Dictionary = {
	"training": null,
	"forest": null,
	"castle": null,
	"dungeon": null,
	"arena": null,
	"desert": null
}

# 地图TileSet配置
var tileset_configs: Dictionary = {
	"training": {
		"tile_size": Vector2i(64, 64),
		"background_color": Color(0.8, 0.8, 0.6),  # 沙色
		"collision_layer": 1,
		"collision_mask": 2
	},
	"forest": {
		"tile_size": Vector2i(64, 64),
		"background_color": Color(0.2, 0.5, 0.2),  # 深绿色
		"collision_layer": 1,
		"collision_mask": 2
	},
	"castle": {
		"tile_size": Vector2i(64, 64),
		"background_color": Color(0.6, 0.4, 0.3),  # 石灰色
		"collision_layer": 1,
		"collision_mask": 2
	},
	"dungeon": {
		"tile_size": Vector2i(64, 64),
		"background_color": Color(0.1, 0.1, 0.2),  # 深蓝色
		"collision_layer": 1,
		"collision_mask": 2
	},
	"arena": {
		"tile_size": Vector2i(64, 64),
		"background_color": Color(0.4, 0.4, 0.4),  # 灰色
		"collision_layer": 1,
		"collision_mask": 2
	},
	"desert": {
		"tile_size": Vector2i(64, 64),
		"background_color": Color(0.9, 0.8, 0.6),  # 沙漠色
		"collision_layer": 1,
		"collision_mask": 2
	}
}

func _ready():
	# 初始化所有TileSet
	_create_tilesets()

func _create_tilesets():
	# 为每个地图类型创建TileSet
	for tileset_name in tileset_configs.keys():
		var tileset = _load_tileset_resource(tileset_name)
		if tileset == null:
			# 如果无法加载资源，创建默认TileSet
			tileset = _create_default_tileset(tileset_name)
		
		# 存储TileSet
		tileset_resources[tileset_name] = tileset
		
		print("Created TileSet for: ", tileset_name)

func _load_tileset_resource(tileset_name: String) -> TileSet:
	# 尝试加载TileSet资源文件
	var resource_path = "res://tilesets/" + tileset_name.capitalize() + ".tres"
	if ResourceLoader.exists(resource_path):
		return load(resource_path) as TileSet
	return null

func _create_default_tileset(tileset_name: String) -> TileSet:
	# 创建默认的TileSet
	var tileset = TileSet.new()
	var config = tileset_configs[tileset_name]
	
	# 设置TileSet属性
	tileset.tile_size = config.tile_size
	
	# 创建物理层 - 修复索引错误
	tileset.add_physics_layer(0)
	tileset.set_physics_layer_collision_layer(0, config.collision_layer)
	tileset.set_physics_layer_collision_mask(0, config.collision_mask)
	
	return tileset

func get_tileset(tileset_name: String) -> TileSet:
	if tileset_name in tileset_resources:
		return tileset_resources[tileset_name]
	return null

func get_tileset_config(tileset_name: String) -> Dictionary:
	if tileset_name in tileset_configs:
		return tileset_configs[tileset_name]
	return {}

func create_map_tilemap(map_name: String) -> TileMap:
	var map_info = Global.get_map_info(map_name)
	var tileset_name = map_info.get("tileset", "training")
	
	var tilemap = TileMap.new()
	var tileset = get_tileset(tileset_name)
	var config = get_tileset_config(tileset_name)
	
	if tileset:
		tilemap.tile_set = tileset
		tilemap.name = map_name + "_TileMap"
		
		# 设置背景颜色
		if config.has("background_color"):
			var background = ColorRect.new()
			background.color = config.background_color
			background.size = Vector2(1280, 720)  # 屏幕大小
			background.z_index = -1  # 放在最底层
			tilemap.add_child(background)
		
		print("Created TileMap for: ", map_name, " with tileset: ", tileset_name)
	
	return tilemap

func generate_map_layout(map_name: String, tilemap: TileMap) -> void:
	# 根据地图类型生成不同的布局
	var map_info = Global.get_map_info(map_name)
	var tileset_name = map_info.get("tileset", "training")
	
	match tileset_name:
		"training":
			_generate_training_layout(tilemap)
		"forest":
			_generate_forest_layout(tilemap)
		"castle":
			_generate_castle_layout(tilemap)
		"dungeon":
			_generate_dungeon_layout(tilemap)
		"arena":
			_generate_arena_layout(tilemap)
		"desert":
			_generate_desert_layout(tilemap)

func _generate_training_layout(tilemap: TileMap):
	# 训练场布局 - 简单的开放区域
	print("Generating training ground layout")
	
	# 创建基础的训练场布局
	# 使用简单的瓦片模式创建训练场
	_create_basic_ground_tiles(tilemap, 20, 15)  # 20x15 瓦片区域

func _generate_forest_layout(tilemap: TileMap):
	# 森林布局 - 密集的树木和障碍物
	print("Generating forest layout")
	
	# 森林地图有更多的障碍物和树木
	# 适合远程角色使用
	_create_forest_layout(tilemap, 25, 20)  # 25x20 瓦片区域

func _generate_castle_layout(tilemap: TileMap):
	# 城堡布局 - 宏伟的建筑结构
	print("Generating castle layout")
	
	# 城堡地图有复杂的建筑结构
	# 适合战术性战斗
	_create_castle_layout(tilemap, 30, 25)  # 30x25 瓦片区域

func _generate_dungeon_layout(tilemap: TileMap):
	# 地牢布局 - 黑暗的地下迷宫
	print("Generating dungeon layout")
	
	# 地牢地图有狭窄的通道和陷阱
	# 适合近距离战斗
	_create_dungeon_layout(tilemap, 20, 20)  # 20x20 瓦片区域

func _generate_arena_layout(tilemap: TileMap):
	# 竞技场布局 - 专业的战斗场地
	print("Generating arena layout")
	
	# 竞技场地图有开放的战斗区域
	# 适合各种类型的战斗
	_create_arena_layout(tilemap, 25, 25)  # 25x25 瓦片区域

func _generate_desert_layout(tilemap: TileMap):
	# 沙漠布局 - 广阔的沙漠环境
	print("Generating desert layout")
	
	# 沙漠地图有广阔的开放区域
	# 适合高速移动和远程战斗
	_create_desert_layout(tilemap, 30, 20)  # 30x20 瓦片区域

# 具体的布局生成函数
func _create_basic_ground_tiles(tilemap: TileMap, width: int, height: int):
	# 创建基础地面瓦片
	for x in range(width):
		for y in range(height):
			# 使用瓦片ID 0 (基础地面)
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
	
	print("Created basic ground tiles: ", width, "x", height)

func _create_forest_layout(tilemap: TileMap, width: int, height: int):
	# 创建森林布局
	for x in range(width):
		for y in range(height):
			# 基础地面
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			
			# 添加一些树木和障碍物
			if x % 5 == 0 and y % 4 == 0 and x > 2 and y > 2:
				# 在特定位置添加树木
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
	
	print("Created forest layout: ", width, "x", height)

func _create_castle_layout(tilemap: TileMap, width: int, height: int):
	# 创建城堡布局
	for x in range(width):
		for y in range(height):
			# 基础地面
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			
			# 添加城堡墙壁
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))
			
			# 添加内部结构
			if x == width / 2 and y > height / 3 and y < height * 2 / 3:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(3, 0))
	
	print("Created castle layout: ", width, "x", height)

func _create_dungeon_layout(tilemap: TileMap, width: int, height: int):
	# 创建地牢布局
	for x in range(width):
		for y in range(height):
			# 基础地面
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			
			# 添加地牢墙壁
			if x % 3 == 0 and y % 3 == 0:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(4, 0))
	
	print("Created dungeon layout: ", width, "x", height)

func _create_arena_layout(tilemap: TileMap, width: int, height: int):
	# 创建竞技场布局
	for x in range(width):
		for y in range(height):
			# 基础地面
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			
			# 添加竞技场边界
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(5, 0))
	
	print("Created arena layout: ", width, "x", height)

func _create_desert_layout(tilemap: TileMap, width: int, height: int):
	# 创建沙漠布局
	for x in range(width):
		for y in range(height):
			# 基础地面
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
			
			# 添加沙漠特征
			if x % 7 == 0 and y % 6 == 0:
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 0))
	
	print("Created desert layout: ", width, "x", height) 