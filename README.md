# Crossing-Binoculars

Crossing-Binoculars is a lightweight and customizable binoculars script for RedM servers. This script allows players to use binoculars and improved binoculars with enhanced functionality, including zoom levels and animations. It is designed to integrate seamlessly with the RSG framework.

## Features
- **Normal and Improved Binoculars**: Different zoom levels for each type.
- **Zoom Functionality**: Scroll to zoom in and out.
- **Animations**: Smooth animations when using binoculars.
- **Weapon Wheel Integration**: Binoculars appear in the weapon wheel.
- **Debug Mode**: Toggle debug messages for development purposes.

## Installation
1. **Download and Extract**:
   - Download the `Crossing-Binoculars` resource.
   - Extract it to your `resources` folder.

2. **Add to `server.cfg`**:
   - Add the following line to your `server.cfg`:
     ```
     ensure Crossing-Binoculars
     ```

3. **Configure Debug Mode**:
   - Open `config.lua` and set `Config.Debug` to `true` or `false` as needed.

## Usage
- **Equip Binoculars**:
  - Use the `weapon_kit_binoculars` or `weapon_kit_binoculars_improved` item from your inventory.
- **Zoom**:
  - Use the scroll wheel to zoom in and out.
- **Remove Binoculars**:
  - Use the item again to remove binoculars from your hands and the weapon wheel.

## Configuration
- `config.lua`:
  - `Config.Debug`: Enable or disable debug messages.

## Compatibility
- Requires the RSG framework.
- Tested on RedM.

## License
This script is released under the MIT License. Feel free to use, modify, and share it.

## Credits
- Developed by **Crossing-Scripts**.

## Support
For issues or suggestions, feel free to open an issue on the GitHub repository or contact the developer.