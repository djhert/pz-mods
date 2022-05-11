# SpiffUI - Inventory

![poster](Contents/mods/SpiffUI-Inventory/poster.png)

## About SpiffUI

SpiffUI (pronounced "Spiffy") is an attempt to make the Project Zomboid in-game UI more player-friendly.  The UI currently acts like a windowing system overtop a video game; similar in behavior to the Openbox/Fluxbox windowing system for a Linux Desktop.  This works as the complexity of the game warrants this, but with little tweaks it can be so much better.

There will be several independent modules released under the SpiffUI name that each change/add their own features.  This allows me to make modifications to these independently, and allow you, the user, to choose which are active.

**Supports B41+. Works in Multiplayer**

## SpiffUI - Inventory
The goal of this mod is to change the default behavior of the Loot and Player Inventories in how they are displayed. The Inventory/Loot Panel rules should make sense in normal usage, but may take a small adjustment to your playstyle. Try it for yourself and let me know what you think!

### Features

- The Inventory and Loot panels are hidden until the player triggers an interaction.

- The Inventory is now bound to the "Tab" key by default.  Pressing Tab will open/close both the inventory and loot panels for the player, the panels cannot be closed when open in this way until you press the key again.

- Bringing the mouse to the top of the screen will show the inventory or loot panel allowing easy access; you can freely switch between which panel is open by moving the mouse.  The panel is automatically hidden after losing mouse focus.

- Panels are no longer able to be resized horizontally or moved around.  They are instead locked to the top of the screen in the default location, and can only be resized vertically.  The "Close", "Info", "Collapse", and "Pin" buttons are also hidden.

- Clicking on a world container will show the loot panel and lock it open until the window is interacted with, an external mouse click, or if you walk away changing the loot panel to a blank floor.

- Option to Hide the "Inventory" button in the left panel.  (I know the keybind, I don't need it)

### Controllers
If playing with a controller the new behavior will not apply and the inventory will behave like Vanilla.

**NOTE:** I HIGHLY recommend that you run both the "Set SpiffUI Recommended Keybinds" and "Run All SpiffUI Resets" after you first install and start the game!

## SpiffUI Configuration

If ModOptions is installed (Recommended) SpiffUI will appear as a category.  This is intended to have common configuration across all of SpiffUI, as well as tools to help configure the game to SpiffUI recommendations.

- Set SpiffUI Recommended Keybinds
    - Default: (None) It's a Button!
    - Sets keybinds for built-in keys to recommended defaults.  A dialog will ask confirming this change, and will display the changes it will make.
- Run All SpiffUI Resets
    - Default: (None) It's a Button!
    - Runs all "Reset" functions for SpiffUI modules.  A user is able to change where the UI is, its size, etc.  This will set this to default.  A dialog will ask confirming this change, and will display the changes it will make.
    - **NOTE:** This will only be usable in-game.

## SpiffUI - Inventory Configuration

- Enable SpiffUI Inventory
    - Default: True
    - Enables all SpiffUI Inventory changes.  Disable to return to all vanilla behavior.
    - **NOTE:** A restart will be required if in-game
- Hide Inventory Button
    - Default: True
    - Hides the Inventory button in the left sidemenu

## Known Issues

- The Dialog Box shown for the SpiffUI options will trigger the game to be unpaused if in-game.
- Controllers do not gain focus to the Settings Dialog; please use a mouse for now.
- Initiating a splitscreen game does not move Player 1's Inventory/Loot panels.  This is vanilla behavior, but complicates things as you cannot move these panels with this mod.  


## Translations

English

Spanish - [ElDoktor](https://github.com/fcastro97)

Thai - [radiusgreenhill](https://github.com/radiusgreenhill)

If you would like to help with translations, please submit a Pull Request.

```
Workshop ID: 2799848602
Mod ID: SpiffUI-Inv
```