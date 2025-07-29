# PVP-game

A comprehensive 2D fighting game built with Godot Engine 4.4.1, featuring a diverse character roster with unique abilities, state management, and bilingual support.

## 🎮 Features

### Character System
- **18 Unique Characters**: Each with distinct stats, abilities, and playstyles
- **Character Attributes**: Health, Movement Speed, Attack Damage, Attack Style
- **Skill System**: Multiple skills per character with cooldown management
- **State Management**: Finite State Machine for character states (idle, walking, attacking, jumping, defeated)

### Global State Management
- **Centralized Game State**: Menu, Character Selection, Map Selection, Playing, Paused
- **Character & Map Selection**: Persistent selection system with validation
- **Scene Navigation**: Seamless flow between character selection → map selection → gameplay
- **Data Persistence**: Selected character and map stored globally across scenes

### Map System
- **5 Unique Maps**: Training Grounds, Mystic Forest, Royal Castle, Dark Dungeon, Battle Arena
- **Map Information**: Difficulty levels, size specifications, and descriptions
- **Collision System**: Proper physics layers for character-ground interactions

### Combat System
- **Mouse-Based Attacks**: Left click for Attack 1, Right click for Attack 2
- **Keyboard Skills**: Number keys 1-3 for special abilities
- **Movement**: WASD controls with smooth character movement
- **Jumping**: Space bar for vertical movement with gravity physics

### User Interface
- **Bilingual Support**: Full Chinese and English language support
- **Character Selection Screen**: Visual character roster with stats display
- **Map Selection Screen**: Interactive map selection with descriptions
- **In-Game HUD**: Health bars, state indicators, and control information
- **Language Switching**: Real-time language change without restart

### Technical Features
- **Physics System**: CharacterBody2D with proper collision detection
- **Animation System**: AnimatedSprite2D for smooth character animations
- **Input Mapping**: Custom input actions for all controls
- **Autoload System**: Global and LanguageManager singletons
- **Scene Management**: Modular scene architecture

## 🎯 Character Roster

| Character | Health | Speed | Damage | Style | Special Abilities |
|-----------|--------|-------|--------|-------|-------------------|
| Knight | 150 | 180 | 35 | Melee | Shield Bash, Battle Cry |
| Wizard | 100 | 160 | 45 | Ranged | Fireball, Teleport |
| Swordsman | 120 | 200 | 40 | Melee | Quick Strike, Parry |
| Priest | 90 | 150 | 30 | Ranged | Heal, Holy Light |
| Skeleton | 80 | 180 | 35 | Melee | Bone Throw, Undead |
| Archer | 110 | 220 | 35 | Ranged | Quick Shot, Precise Shot |
| Werewolf | 130 | 190 | 45 | Melee | Howl, Transform |
| Slime | 70 | 140 | 25 | Melee | Acid Spit, Split |
| Soldier | 140 | 170 | 40 | Melee | Grenade, Tactical |
| Armored Axeman | 160 | 150 | 50 | Melee | Heavy Strike, Armor |
| Elite Orc | 180 | 160 | 55 | Melee | Berserker Rage, Charge |
| Knight Templar | 170 | 165 | 45 | Melee | Holy Strike, Protection |
| Lancer | 130 | 185 | 42 | Melee | Pierce, Charge |
| Armored Orc | 190 | 155 | 60 | Melee | Heavy Armor, Smash |
| Armored Skeleton | 120 | 175 | 38 | Melee | Bone Armor, Curse |
| Greatsword Skeleton | 140 | 165 | 48 | Melee | Heavy Slash, Fear |
| Orc | 160 | 170 | 45 | Melee | Tribal Rage, Roar |
| Orc Rider | 150 | 200 | 50 | Melee | Mounted Charge, Whip |

## 🗺️ Available Maps

| Map | Difficulty | Size | Description |
|-----|------------|------|-------------|
| Training Grounds | 1 | Small | Basic arena for practice |
| Mystic Forest | 2 | Medium | Dense forest with obstacles |
| Royal Castle | 3 | Large | Grand castle with multiple levels |
| Dark Dungeon | 4 | Medium | Underground maze with traps |
| Battle Arena | 5 | Large | Professional fighting arena |

## 🎮 Controls

### Movement
- **W/A/S/D**: Move character in four directions
- **SPACE**: Jump (with gravity physics)

### Combat
- **Left Mouse Click**: Attack 1 (character-specific)
- **Right Mouse Click**: Attack 2 (character-specific)
- **1/2/3 Keys**: Use special skills

### Navigation
- **SPACE** (in menus): Confirm selection and proceed
- **Mouse**: Click buttons and select options

## 🛠️ Technical Specifications

### Engine & Version
- **Godot Engine**: 4.4.1 Stable
- **Scripting Language**: GDScript
- **Graphics API**: Vulkan 1.4.303

### Project Structure
```
character_roster_game/
├── scenes/
│   ├── Main.tscn          # Character selection screen
│   ├── MapSelection.tscn   # Map selection screen
│   └── Game.tscn          # Main gameplay scene
├── scripts/
│   ├── Global.gd          # Global state management
│   ├── LanguageManager.gd # Bilingual support
│   ├── Main.gd           # Character selection logic
│   ├── MapSelection.gd    # Map selection logic
│   ├── Game.gd           # Main game logic
│   └── [Character].gd    # Individual character scripts
├── characters/
│   └── [Character].tscn  # Character scene files
└── assets/
    ├── sprites/          # Character sprites
    ├── sounds/           # Audio files
    └── fonts/            # Font assets
```

### Key Systems
- **Global State Management**: Centralized game state and data persistence
- **Finite State Machine**: Character state management (idle, walking, attacking, etc.)
- **Collision System**: Layer-based physics (Characters: Layer 2, Ground: Layer 1)
- **Animation System**: AnimatedSprite2D for character animations
- **Input System**: Custom input mapping for all controls
- **UI System**: Responsive UI with bilingual support

## 🚀 Getting Started

### Prerequisites
- Godot Engine 4.4.1 or later
- Windows 10/11 (tested on Windows 10)

### Installation
1. Clone or download the project
2. Open Godot Engine
3. Import the project by selecting the `project.godot` file
4. Run the project from the editor or build an executable

### Running the Game
1. **Character Selection**: Choose from 18 unique characters
2. **Map Selection**: Select one of 5 available maps
3. **Gameplay**: Use WASD to move, mouse clicks for attacks, space to jump
4. **Language**: Switch between English and Chinese using the language buttons

## 🔧 Development Status

### ✅ Completed Features
- [x] 18-character roster with unique stats and abilities
- [x] Global state management system
- [x] Map selection system (5 maps)
- [x] Bilingual support (Chinese/English)
- [x] Mouse-based combat system
- [x] Keyboard movement and jumping
- [x] Character state management (FSM)
- [x] Collision system with proper layers
- [x] UI system with health bars and status
- [x] Scene navigation and flow
- [x] Input mapping and controls
- [x] Animation system integration

### 🚧 Current Development
- [x] Global state management implementation
- [x] Map selection system
- [x] Enhanced character selection flow
- [x] Bilingual map translations
- [x] Collision layer system

### 🔮 Future Enhancements
- [ ] Multiplayer support
- [ ] Additional character abilities
- [ ] More maps and environments
- [ ] Sound effects and music
- [ ] Particle effects for combat
- [ ] Save/load system
- [ ] Character progression
- [ ] Tournament mode
- [ ] AI opponents
- [ ] Mobile support

## 🐛 Known Issues
- Some character scene files have invalid UID warnings (non-critical)
- Collision layer warnings during development (resolved)

## 📝 License
This project is developed for educational and entertainment purposes.

## 🤝 Contributing
Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Engine**: Godot 4.4.1  
**Status**: Active Development 