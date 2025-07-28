# Character Roster Game

A Godot 4.2 project featuring a diverse roster of characters with unique abilities and state management.

## Core Features

### Character Roster System
- **Warrior**: High health, melee combat specialist
- **Mage**: Low health, ranged magic user
- **Archer**: Balanced stats, ranged combat specialist

### Character Attributes
Each character has unique stats:
- **Health (HP)**: Maximum and current health points
- **Movement Speed**: How fast the character moves
- **Attack Damage**: Base damage output
- **Attack Style**: Melee or ranged combat
- **Attack Range**: Distance for attacks
- **Skills**: Unique abilities for each character

### State Management
Finite State Machine (FSM) handles character states:
- **Idle**: Default state when not moving or acting
- **Walking**: Moving at normal speed
- **Running**: Moving at increased speed (hold Shift)
- **Attacking**: Performing attack animations
- **Taking Damage**: When hit by enemies
- **Defeated**: When health reaches zero

## Controls

### Movement
- **WASD**: Move character
- **Shift + Movement**: Run (increased speed)

### Combat
- **SPACE**: Basic attack
- **1**: Skill 1 (character-specific)
- **2**: Skill 2 (character-specific)
- **3**: Skill 3 (character-specific)

## Character Details

### Warrior
- **Health**: 150 HP
- **Movement Speed**: 180
- **Attack Damage**: 35
- **Attack Style**: Melee
- **Skills**:
  - Shield Bash (1): High damage melee attack
  - Battle Cry (2): Buffs attack damage and movement speed

### Mage
- **Health**: 80 HP
- **Movement Speed**: 160
- **Attack Damage**: 25
- **Attack Style**: Ranged
- **Skills**:
  - Fireball (1): High damage ranged attack
  - Teleport (2): Move to mouse position

### Archer
- **Health**: 100 HP
- **Movement Speed**: 220
- **Attack Damage**: 30
- **Attack Style**: Ranged
- **Skills**:
  - Multi Shot (1): Fires multiple arrows
  - Dash (2): Quick movement in facing direction

## Project Structure

```
character_roster_game/
├── project.godot          # Main project file
├── scenes/
│   ├── Main.tscn         # Character selection screen
│   └── Game.tscn         # Main game scene
├── scripts/
│   ├── Character.gd       # Base character class
│   ├── StateMachine.gd    # State machine system
│   ├── State.gd          # Base state class
│   ├── States.gd         # All state implementations
│   ├── Main.gd           # Main scene script
│   ├── Game.gd           # Game scene script
│   ├── Warrior.gd        # Warrior character
│   ├── Mage.gd           # Mage character
│   └── Archer.gd         # Archer character
├── characters/
│   ├── Warrior.tscn      # Warrior scene
│   ├── Mage.tscn         # Mage scene
│   └── Archer.tscn       # Archer scene
├── assets/
│   └── icon.svg          # Project icon
└── README.md             # This file
```

## How to Run

1. Open the project in Godot 4.2 or later
2. Run the project (F5 or Play button)
3. Select a character from the main menu
4. Press SPACE to start the game
5. Use WASD to move, SPACE to attack, and number keys for skills

## Technical Implementation

### State Machine Pattern
The game uses a Finite State Machine to manage character states:
- Each state is a separate class inheriting from `State`
- States handle their own logic and transitions
- The `StateMachine` class manages state transitions

### Character System
- Base `Character` class provides common functionality
- Each character type extends the base class
- Characters have unique stats and abilities
- Skills are implemented with cooldown systems

### Input System
- Uses Godot's input map system
- Supports both keyboard and potential gamepad input
- Skills are bound to number keys (1, 2, 3)

## Future Enhancements

- Add more characters with unique abilities
- Implement enemy AI and combat system
- Add visual effects and animations
- Create levels and progression system
- Add sound effects and music
- Implement save/load system 