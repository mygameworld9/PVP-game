extends Node

# Language Manager for Chinese/English support
var current_language: String = "en"  # "en" for English, "zh" for Chinese

# Dictionary to store all text in both languages
var translations = {
	"en": {
		"game_title": "Character Roster Game",
		"select_character": "Select a character to begin",
		"knight_selected": "Knight selected! Press SPACE to start game",
		"wizard_selected": "Wizard selected! Press SPACE to start game",
		"swordsman_selected": "Swordsman selected! Press SPACE to start game",
		"priest_selected": "Priest selected! Press SPACE to start game",
		"skeleton_selected": "Skeleton selected! Press SPACE to start game",
		"archer_selected": "Archer selected! Press SPACE to start game",
		"werewolf_selected": "Werewolf selected! Press SPACE to start game",
		"slime_selected": "Slime selected! Press SPACE to start game",
		"soldier_selected": "Soldier selected! Press SPACE to start game",
		"armored_axeman_selected": "Armored Axeman selected! Press SPACE to start game",
		"elite_orc_selected": "Elite Orc selected! Press SPACE to start game",
		"knight_templar_selected": "Knight Templar selected! Press SPACE to start game",
		"lancer_selected": "Lancer selected! Press SPACE to start game",
			"armored_orc_selected": "Armored Orc selected! Press SPACE to start game",
	"armored_skeleton_selected": "Armored Skeleton selected! Press SPACE to start game",
	"greatsword_skeleton_selected": "Greatsword Skeleton selected! Press SPACE to start game",
		"knight": "Knight",
		"wizard": "Wizard",
		"swordsman": "Swordsman",
		"priest": "Priest",
		"skeleton": "Skeleton",
		"archer": "Archer",
		"werewolf": "Werewolf",
		"slime": "Slime",
		"soldier": "Soldier",
		"armored_axeman": "Armored Axeman",
		"elite_orc": "Elite Orc",
			"knight_templar": "Knight Templar",
	"lancer": "Lancer",
	"armored_orc": "Armored Orc",
	"armored_skeleton": "Armored Skeleton",
	"greatsword_skeleton": "Greatsword Skeleton",
	"health": "Health",
		"state": "State",
		"controls": "Controls:",
		"move": "WASD - Move",
		"jump": "SPACE - Jump",
		"attack1": "Left Click - Attack 1",
		"attack2": "Right Click - Attack 2",
		"skill1": "1 - Skill 1",
		"skill2": "2 - Skill 2",
		"back_to_menu": "Back to Menu",
		"language": "Language",
		"english": "English",
		"chinese": "中文",
		"select_map": "Select a Map",
		"map_selected": "Map selected! Press SPACE to start game",
		"back_to_character_selection": "Back to Character Selection",
		"training_grounds": "Training Grounds",
		"mystic_forest": "Mystic Forest",
		"royal_castle": "Royal Castle",
		"dark_dungeon": "Dark Dungeon",
		"battle_arena": "Battle Arena",
		"desert_oasis": "Desert Oasis"
	},
	"zh": {
		"game_title": "角色阵容游戏",
		"select_character": "选择一个角色开始游戏",
		"knight_selected": "已选择骑士！按空格键开始游戏",
		"wizard_selected": "已选择法师！按空格键开始游戏",
		"swordsman_selected": "已选择剑士！按空格键开始游戏",
		"priest_selected": "已选择牧师！按空格键开始游戏",
		"skeleton_selected": "已选择骷髅！按空格键开始游戏",
		"archer_selected": "已选择弓箭手！按空格键开始游戏",
		"werewolf_selected": "已选择狼人！按空格键开始游戏",
		"slime_selected": "已选择史莱姆！按空格键开始游戏",
		"soldier_selected": "已选择士兵！按空格键开始游戏",
		"armored_axeman_selected": "已选择装甲斧手！按空格键开始游戏",
		"elite_orc_selected": "已选择精英兽人！按空格键开始游戏",
		"knight_templar_selected": "已选择圣殿骑士！按空格键开始游戏",
		"lancer_selected": "已选择枪兵！按空格键开始游戏",
			"armored_orc_selected": "已选择装甲兽人！按空格键开始游戏",
	"armored_skeleton_selected": "已选择装甲骷髅！按空格键开始游戏",
	"greatsword_skeleton_selected": "已选择巨剑骷髅！按空格键开始游戏",
		"knight": "骑士",
		"wizard": "法师",
		"swordsman": "剑士",
		"priest": "牧师",
		"skeleton": "骷髅",
		"archer": "弓箭手",
		"werewolf": "狼人",
		"slime": "史莱姆",
		"soldier": "士兵",
		"armored_axeman": "装甲斧手",
		"elite_orc": "精英兽人",
		"knight_templar": "圣殿骑士",
		"lancer": "枪兵",
			"armored_orc": "装甲兽人",
	"armored_skeleton": "装甲骷髅",
	"greatsword_skeleton": "巨剑骷髅",
		"health": "生命值",
		"state": "状态",
		"controls": "控制:",
		"move": "WASD - 移动",
		"jump": "空格 - 跳跃",
		"attack1": "左键 - 攻击1",
		"attack2": "右键 - 攻击2",
		"skill1": "1 - 技能1",
		"skill2": "2 - 技能2",
		"back_to_menu": "返回菜单",
		"language": "语言",
		"english": "English",
		"chinese": "中文",
		"select_map": "选择地图",
		"map_selected": "地图已选择！按空格键开始游戏",
		"back_to_character_selection": "返回角色选择",
		"training_grounds": "训练场",
		"mystic_forest": "神秘森林",
		"royal_castle": "皇家城堡",
		"dark_dungeon": "黑暗地牢",
		"battle_arena": "战斗竞技场",
		"desert_oasis": "沙漠绿洲"
	}
}

func _ready():
	# Make this a singleton
	process_mode = Node.PROCESS_MODE_ALWAYS

func get_text(key: String) -> String:
	if current_language in translations and key in translations[current_language]:
		return translations[current_language][key]
	# Fallback to English if translation not found
	if key in translations["en"]:
		return translations["en"][key]
	return key

func set_language(lang: String):
	if lang in translations:
		current_language = lang
		# Emit signal to update UI
		language_changed.emit()

# Signal to notify when language changes
signal language_changed 