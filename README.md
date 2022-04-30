# json.nvim

json.nvim provides convience for extracting JSON strings in cursor line, especially for structrured log files which have inlined json.

![demo](https://user-images.githubusercontent.com/3747445/166113768-d12cb20a-5b8b-486f-a3ff-7c005a25be13.gif)

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
