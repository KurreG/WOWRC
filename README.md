# kuga00 AddOn - Resource Counter

A World of Warcraft addon that displays class-specific resource counters with customizable colors, position, and display options. Supports all 13 classes with spec-specific resource tracking.

## What's New in 0.5

### ✨ New Class Support
- **Demon Hunter**: Fury tracking
- **Shaman**: Maelstrom (Elemental spec)
- **Priest**: Insanity (Shadow spec)
- **Mage**: Arcane Charges (Arcane spec)

### 🎨 UI Improvements
- **3-Column Class Layout**: Reorganized options panel for easier navigation of all 13 classes
- **Optimized Window Size**: 420x850 dimensions for better visibility of all controls
- **Real-time Updates**: All settings apply immediately without reloading

### ⚠️ Technical Notes
- Fury and Maelstrom display in white due to WoW API secret value restrictions (threshold highlighting unavailable in PvP areas)
- Removed aura-based tracking (Icicles, Soul Fragments) to prevent combat errors

## Features

### Resource Tracking by Class
- **Rogue**: Combo Points + Energy
- **Warrior**: Rage
- **Hunter**: Focus
- **Warlock**: Soul Shards
- **Death Knight**: Runic Power
- **Paladin**: Holy Power
- **Monk**: Chi (Windwalker spec only)
- **Druid**: 
  - Guardian spec (Bear Form): Rage
  - Feral spec (Cat Form): Combo Points
- **Priest**: Insanity (Shadow spec only)
- **Mage**: Arcane Charges (Arcane spec only)
- **Shaman**: Maelstrom (Elemental spec only)
- **Demon Hunter**: Fury

### Threshold Color Highlighting
- **Chi**: Highlights green when ≥ 2 (configurable)
- **Holy Power**: Highlights green when ≥ 3 (configurable)
- **Combo Points**: Highlights green when ≥ 5 (configurable)
- Other resources display in white (threshold highlighting not available due to WoW API limitations)

### Display Options
- **Show/Hide Power Names**: Toggle between "Chi: 5" or just "5"
- **8 Text Sizes**: Small (18), Medium (20), Large (24), Extra Large (28), Huge (32), Massive (36), Giant (40), Colossal (44)
- **Customizable Position**: Move the counter anywhere on screen with sliders
  - Horizontal slider: -500 to 500 (left/right)
  - Vertical slider: -500 to 500 (down/up)
  - Reset button to restore default position
- **Attach to Cursor**: Optionally attach the counter to the mouse cursor
  - Position sliders act as X/Y offsets relative to the cursor
- **Custom Highlight Color**: Customize the threshold highlight color (default: green)
  - Color displayed on the color picker button
  - Applies to Chi, Holy Power, and Combo Points when thresholds are met

### Per-Class Control
- Enable/disable resource tracking for any class
- Settings persist across sessions

### UI Integration
- Full options panel with resizable window (420x850) accessible via:
  - `ESC` → `Interface` → `AddOns` → `kuga00`
  - `/kuga00 opt` command
- 3-column class layout for easy management of all 13 classes
- All settings update in real-time

### Slash Commands
- `/kuga00 opt` - Open options panel
- `/kuga00 option` - Open options panel (alias)
- `/kuga00 enable <CLASS>` - Enable resource tracking for a class
- `/kuga00 disable <CLASS>` - Disable resource tracking for a class
- `/kuga00 status` - Show enable/disable status for all classes
- `/kuga00 cursor on|off` - Attach/detach the counter to the cursor

### Usage
```
/kuga00 enable|disable <CLASS>
/kuga00 status
/kuga00 cursor on|off
/kuga00 opt|option
```

## Installation
1. Extract the `kuga00` folder to your `World of Warcraft\_retail_\Interface\AddOns\` directory
2. Log in to WoW and reload the UI (`/reload`)
3. Access options via Interface → AddOns → kuga00

## Configuration
All settings are accessible through the in-game options panel:
- Toggle which classes to track (3-column layout)
- Adjust threshold values for Chi, Holy Power, and Combo Points
- Change text size and display style
- Customize highlight color (color picker shows current color)
- Position the counter anywhere on screen
- Attach to cursor for dynamic positioning

Settings are saved in `SavedVariables\kuga00Settings.lua` including:
- Enabled classes
- Threshold values (chi, holyPower, comboPoints)
- Highlight color (RGB values)
- Text size
- Counter position (x, y coordinates)
- Show power names toggle
- Attach to cursor setting

## Known Limitations
- **WoW API Restrictions**: Some resources (Fury, Maelstrom) cannot use threshold highlighting in arenas/rated PvP due to Blizzard's "secret value" protection
- **Protected Functions**: Aura-based tracking (e.g., Icicles, Soul Fragments) would cause errors during combat and are not supported
- Resources using secret values will display as 0 in restricted PvP areas but work normally in PvE content

## Version
Current: 0.5
Interface: 120001 (The War Within)

## Author
kuga00
