# kuga00 AddOn - Resource Counter

A World of Warcraft addon that displays class-specific resource counters (Combo Points, Chi, Holy Power, Energy, Rage, Focus, Runic Power, Soul Shards) with customizable thresholds, colors, position, and display options.

## Features

### Resource Tracking
- **Rogue**: Combo Points + Energy
- **Warrior**: Rage
- **Hunter**: Focus
- **Warlock**: Soul Shards
- **Death Knight**: Runic Power
- **Paladin**: Holy Power
- **Monk**: Chi (Windwalker only)
- **Druid**: Rage (Guardian bear form) / Combo Points (Feral cat form)
- **Priest**: Insanity (Shadow only)
- **Mage**: Arcane Charges (Arcane only)
- **Shaman**: Maelstrom (Elemental only)
- **Demon Hunter**: Fury

### Display Options
- **Show/Hide Power Names**: Toggle between "Chi: 5" or just "5"
- **8 Text Sizes**: Small (18), Medium (20), Large (24), Extra Large (28), Huge (32), Massive (36), Giant (40), Colossal (44)
- **Customizable Position**: Move the counter anywhere on screen with sliders
  - Horizontal slider: -500 to 500 (left/right)
  - Vertical slider: -500 to 500 (down/up)
  - Reset button to restore default position
- **Attach to Cursor**: Optionally attach the counter to the mouse cursor
  - Position sliders act as X/Y offsets relative to the cursor
- **Customizable Thresholds**: Set color highlight thresholds for Chi, Holy Power, and Combo Points
- **Custom Highlight Color**: Customize the color when resources reach threshold values (displayed on color picker button)

### Per-Class Control
- Enable/disable resource tracking for any class
- Settings persist across sessions

### UI Integration
- Full options panel with resizable window accessible via:
  - `ESC` → `Interface` → `AddOns` → `kuga00`
  - `/kuga00 opt` command
- Options window can be moved and resized
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
- Toggle which classes to track
- Adjust threshold values for color highlighting
- Change text size and display style
- Customize highlight color (color picker shows current color)
- Position the counter anywhere on screen
- Resize the options window

Settings are saved in `SavedVariables\kuga00Settings.lua` including:
- Enabled classes
- Threshold values
- Highlight color
- Text size
- Counter position (x, y coordinates)
- Show power names toggle
- Attach to cursor (position sliders act as offsets when enabled)

## Version
Current: 0.3beta
Interface: 120001 (The War Within)

## Author
kuga00
