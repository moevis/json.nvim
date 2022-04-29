# json.nvim

json.nvim provides convience for extracting JSON strings in cursor line. I wrote this plugin in order to extract json from log file.

## Requirements

Neovim 0.7+

## Installation

With packer

```lua
use 'moevis/json.nvim'
```

## Commands

- `:JsonExtract`: Extract JSON from current line
- `:JsonNext`: Switch to next json (when there are multiple jsons in the line). You can access it with shortcut `]]` in `json.nvim` window.
- `:JsonPrev`: Switch to previous json (when there are multiple jsons in the line). You can access it with shorcut `[[` in `json.nvim` window.
