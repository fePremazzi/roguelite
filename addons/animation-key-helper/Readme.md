# Animation Keyframe Helper for Godot 4.x

A useful plugin for Godot 4.x that simplifies working with animation keyframes by evenly distributing them across the animation duration.

## Features

- **Even Keyframe Distribution**: Distributes keyframes evenly across a desired time range
- **Selective Track Editing**: Choose specifically which animation tracks to modify
- **Flexible Duration Settings**: Keep the existing animation length or adjust it as needed
- **Intuitive User Interface**: Easy-to-use button in the Animation Editor

## Installation

1. Download the plugin
2. Copy the addons folder containing `addons/animationkeyhelper` in your Godot project
3. Activate the plugin in Project Settings under "Plugins"

## Usage

### Basic Usage

1. Open the Animation Editor in Godot
2. Select or create an animation and add keyframes if none are available
3. Click the "Scale Keyframes" button that appears in the animation toolbar
4. Select the tracks you want to edit
5. Enter the desired target duration for the frames to be distributed between
6. Decide whether the animation length should be adjusted
7. Click "OK" to evenly distribute the keyframes

### Use Cases

- **Precise Timing**: Distribute keyframes exactly evenly for uniform animations
- **Adjust Animation Length**: Extend or shorten an animation without losing relative timing
- **Selective Editing**: Edit only specific aspects of an animation (e.g., only position tracks)
- **Quick Animation Creation**: Quickly create animations with evenly distributed keyframes as a starting point

## Supported Godot Versions

- Tested with Godot 4.4
- Should be compatible with most Godot 4.x versions
