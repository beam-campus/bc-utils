# Working with Colors in BCUtils

The `BCUtils.ColorFuncs` module provides a comprehensive set of functions for working with terminal colors and text effects using ANSI escape codes. This guide covers all the capabilities and features of the module.

## Table of Contents

- [Overview](#overview)
- [Basic Usage](#basic-usage)
- [Color Palette](#color-palette)
- [Text Effects](#text-effects)
- [Advanced Functions](#advanced-functions)
- [True Color Support](#true-color-support)
- [Auto-Generated Combinations](#auto-generated-combinations)
- [Practical Examples](#practical-examples)
- [Best Practices](#best-practices)
- [Color Reference](#color-reference)

## Overview

The `BCUtils.ColorFuncs` module offers:

- **73 named colors** from basic ANSI to extended 256-color palette
- **9 text effects** (bold, italic, underline, etc.)
- **True color support** (24-bit RGB)
- **Hex color support** for web-style colors
- **Auto-generated color combinations** for all foreground/background pairs
- **Utility functions** for easy color manipulation

## Basic Usage

### Simple Foreground Colors

```elixir
# Basic usage
ColorFuncs.fg(:red) <> "Red text" <> ColorFuncs.reset()

# With effects
ColorFuncs.fg(:blue, [:bold]) <> "Bold blue text" <> ColorFuncs.reset()

# Multiple effects
ColorFuncs.fg(:green, [:bold, :underline]) <> "Bold underlined green" <> ColorFuncs.reset()
```

### Background Colors

```elixir
# Simple background
ColorFuncs.bg(:yellow) <> "Text on yellow background" <> ColorFuncs.reset()

# Foreground + background
ColorFuncs.fg(:white) <> ColorFuncs.bg(:black) <> "White on black" <> ColorFuncs.reset()
```

### Convenience Functions

```elixir
# Wrap text with automatic reset
ColorFuncs.wrap("Hello World", :purple, [:bold])

# Apply effects only
ColorFuncs.effect(:italic) <> "Italic text" <> ColorFuncs.reset()
```

## Color Palette

The module includes 73 carefully selected colors organized into categories:

### Standard ANSI Colors (16)
- **Basic**: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
- **Bright**: `bright_black`, `bright_red`, `bright_green`, `bright_yellow`, `bright_blue`, `bright_magenta`, `bright_cyan`, `bright_white`

### Extended Colors (20)
Popular colors for enhanced aesthetics:
- `orange`, `purple`, `pink`, `lime`, `navy`, `maroon`, `olive`, `teal`
- `silver`, `gold`, `coral`, `salmon`, `khaki`, `violet`, `indigo`, `crimson`
- `forest`, `sky`, `rose`, `mint`

### Vibrant Colors (20)
Rich, saturated colors:
- `turquoise`, `aqua`, `brown`, `tan`, `beige`, `ivory`
- `lavender`, `plum`, `orchid`, `peach`, `apricot`, `lemon`
- `chartreuse`, `emerald`, `jade`, `sapphire`, `ruby`, `amber`, `bronze`, `copper`

### Nature-Inspired Colors (10)
Earth and nature tones:
- `grass`, `leaf`, `ocean`, `sand`, `stone`, `clay`, `earth`, `bark`, `moss`, `fern`

### Modern/Tech Colors (10)
Cyberpunk and tech aesthetics:
- `neon_green`, `neon_blue`, `neon_pink`, `electric`, `plasma`
- `laser`, `matrix`, `cyber`, `terminal`, `hacker`

### Grayscale (12)
Fine-grained grayscale options:
- `gray1` through `gray12` (from darkest to lightest)

## Text Effects

The module supports 9 text effects that can be combined:

```elixir
effects = [
  :bold,           # Bold/bright text
  :dim,            # Dimmed text
  :italic,         # Italic text (not universally supported)
  :underline,      # Underlined text
  :blink,          # Slow blink
  :rapid_blink,    # Rapid blink
  :reverse,        # Reverse video (swap fg/bg colors)
  :hidden,         # Hidden text
  :strikethrough   # Strikethrough text
]

# Single effect
ColorFuncs.fg(:red, [:bold])

# Multiple effects
ColorFuncs.fg(:blue, [:bold, :underline, :italic])

# Effect only (no color change)
ColorFuncs.effect(:bold)
```

## Advanced Functions

### The `tui` Function

The main function for creating complex color combinations:

```elixir
# Basic syntax: tui(foreground, background, effects)
ColorFuncs.tui(:white, :blue, [:bold])
ColorFuncs.tui(:yellow, :red, [:bold, :underline])
ColorFuncs.tui(:green, :black, [])
```

### Utility Functions

```elixir
# List all available colors
ColorFuncs.available_colors()

# List all available effects  
ColorFuncs.available_effects()

# Reset all formatting
ColorFuncs.reset()
```

## True Color Support

### RGB Colors

Use any RGB color combination:

```elixir
# RGB foreground (values 0-255)
ColorFuncs.rgb_fg(255, 128, 0)    # Orange
ColorFuncs.rgb_fg(64, 224, 208)   # Turquoise
ColorFuncs.rgb_fg(255, 20, 147)   # Deep pink

# RGB background
ColorFuncs.rgb_bg(25, 25, 112)    # Midnight blue
ColorFuncs.rgb_bg(0, 0, 0)        # True black

# Combined usage
text = ColorFuncs.rgb_fg(255, 255, 255) <> 
       ColorFuncs.rgb_bg(0, 0, 0) <> 
       "White on true black" <> 
       ColorFuncs.reset()
```

### Hex Colors

Use web-style hex colors:

```elixir
# Hex foreground
ColorFuncs.hex_fg("#FF8000")      # Orange
ColorFuncs.hex_fg("#7aa2f7")      # Nice blue
ColorFuncs.hex_fg("#9ece6a")      # Green

# Hex background  
ColorFuncs.hex_bg("#1a1b26")      # Dark background
ColorFuncs.hex_bg("#ff0000")      # Red background

# Both formats supported
ColorFuncs.hex_fg("FF8000")       # Without #
ColorFuncs.hex_fg("#FF8000")      # With #
```

## Auto-Generated Combinations

The module automatically generates functions for all foreground/background color combinations:

```elixir
# Pattern: {foreground}_on_{background}
ColorFuncs.red_on_white()
ColorFuncs.blue_on_yellow()
ColorFuncs.white_on_black()
ColorFuncs.green_on_gray5()
ColorFuncs.neon_green_on_black()
ColorFuncs.purple_on_bright_white()

# Usage example
header = ColorFuncs.white_on_blue() <> " HEADER " <> ColorFuncs.reset()
error = ColorFuncs.white_on_red() <> " ERROR " <> ColorFuncs.reset()
success = ColorFuncs.black_on_green() <> " SUCCESS " <> ColorFuncs.reset()
```

This generates **5,329 functions** (73 × 73) for instant access to any color combination!

## Practical Examples

### Creating a Status Bar

```elixir
defmodule StatusBar do
  alias BCUtils.ColorFuncs, as: CF

  def render(status, message) do
    case status do
      :success -> 
        CF.wrap(" ✓ ", :black, [], :bright_green) <> 
        CF.wrap(" #{message} ", :bright_green)
        
      :error -> 
        CF.wrap(" ✗ ", :white, [], :red) <> 
        CF.wrap(" #{message} ", :red)
        
      :warning -> 
        CF.wrap(" ⚠ ", :black, [], :yellow) <> 
        CF.wrap(" #{message} ", :yellow)
        
      :info -> 
        CF.wrap(" ℹ ", :white, [], :blue) <> 
        CF.wrap(" #{message} ", :blue)
    end
  end
end

# Usage
IO.puts(StatusBar.render(:success, "Database connected"))
IO.puts(StatusBar.render(:error, "Connection failed"))
```

### Syntax Highlighting

```elixir
defmodule SyntaxHighlight do
  alias BCUtils.ColorFuncs, as: CF

  def keyword(text), do: CF.wrap(text, :purple, [:bold])
  def string(text), do: CF.wrap(text, :green)
  def number(text), do: CF.wrap(text, :cyan)
  def comment(text), do: CF.wrap(text, :gray7, [:italic])
  def function_name(text), do: CF.wrap(text, :blue, [:bold])

  def highlight_elixir(code) do
    code
    |> String.replace(~r/\bdef\b/, keyword("def"))
    |> String.replace(~r/"[^"]*"/, &string/1)
    |> String.replace(~r/\d+/, &number/1)
    |> String.replace(~r/#.*$/, &comment/1)
  end
end
```

### Progress Indicators

```elixir
defmodule Progress do
  alias BCUtils.ColorFuncs, as: CF

  def bar(percentage, width \\ 50) do
    filled = round(percentage * width / 100)
    empty = width - filled
    
    filled_bar = CF.wrap(String.duplicate("█", filled), :bright_green)
    empty_bar = CF.wrap(String.duplicate("░", empty), :gray3)
    percentage_text = CF.wrap(" #{percentage}% ", :bright_white, [:bold])
    
    "[#{filled_bar}#{empty_bar}]#{percentage_text}"
  end
  
  def spinner(frame) do
    frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    current = Enum.at(frames, rem(frame, length(frames)))
    CF.wrap(current, :cyan) <> " Loading..."
  end
end

# Usage
IO.puts(Progress.bar(75))
IO.puts(Progress.spinner(3))
```

### Log Level Formatting

```elixir
defmodule LogFormatter do
  alias BCUtils.ColorFuncs, as: CF

  def format_level(:debug), do: CF.wrap("DEBUG", :gray8)
  def format_level(:info),  do: CF.wrap("INFO ", :bright_cyan)
  def format_level(:warn),  do: CF.wrap("WARN ", :yellow, [:bold])
  def format_level(:error), do: CF.wrap("ERROR", :red, [:bold])
  def format_level(:fatal), do: CF.wrap("FATAL", :white, [:bold], :red)

  def format_log(level, module, message) do
    timestamp = CF.wrap(DateTime.utc_now() |> to_string(), :gray6)
    level_text = format_level(level)
    module_text = CF.wrap("[#{module}]", :blue)
    
    "#{timestamp} #{level_text} #{module_text} #{message}"
  end
end
```

### Terminal UI Components

```elixir
defmodule TerminalUI do
  alias BCUtils.ColorFuncs, as: CF

  def header(title) do
    width = 60
    padding = div(width - String.length(title) - 2, 2)
    
    top = CF.wrap(String.duplicate("═", width), :bright_blue)
    middle = CF.wrap("║", :bright_blue) <> 
             String.duplicate(" ", padding) <>
             CF.wrap(title, :bright_white, [:bold]) <>
             String.duplicate(" ", padding) <>
             CF.wrap("║", :bright_blue)
    bottom = CF.wrap(String.duplicate("═", width), :bright_blue)
    
    [top, middle, bottom] |> Enum.join("\n")
  end

  def menu_item(text, selected \\ false) do
    if selected do
      CF.wrap(" ▶ #{text} ", :black, [:bold], :bright_cyan)
    else
      CF.wrap("   #{text} ", :bright_white)
    end
  end

  def table_row(cells, colors \\ []) do
    cells
    |> Enum.with_index()
    |> Enum.map(fn {cell, idx} ->
      color = Enum.at(colors, idx, :white)
      CF.wrap(String.pad_trailing(cell, 15), color)
    end)
    |> Enum.join(" │ ")
  end
end
```

## Best Practices

### 1. Always Reset

Always use `ColorFuncs.reset()` or the `wrap/3` function to avoid color bleeding:

```elixir
# Good
text = ColorFuncs.fg(:red) <> "Error message" <> ColorFuncs.reset()

# Better
text = ColorFuncs.wrap("Error message", :red)
```

### 2. Check Terminal Capabilities

Not all terminals support all features:

```elixir
# Some terminals don't support italic
text = if terminal_supports_italic?() do
  ColorFuncs.wrap("Italic text", :blue, [:italic])
else
  ColorFuncs.wrap("Bold text", :blue, [:bold])
end
```

### 3. Use Semantic Color Functions

Create semantic wrappers for better maintainability:

```elixir
defmodule Colors do
  alias BCUtils.ColorFuncs, as: CF
  
  def error(text), do: CF.wrap(text, :red, [:bold])
  def success(text), do: CF.wrap(text, :green, [:bold])
  def warning(text), do: CF.wrap(text, :yellow, [:bold])
  def info(text), do: CF.wrap(text, :blue)
  def debug(text), do: CF.wrap(text, :gray8)
end
```

### 4. Consider Accessibility

Choose colors that work well together and are accessible:

```elixir
# Good contrast
ColorFuncs.wrap("Important", :bright_white, [:bold], :red)

# Poor contrast (avoid)
ColorFuncs.wrap("Hard to read", :yellow, [], :white)
```

### 5. Use Soft Colors for Large Text Blocks

For readability, prefer softer colors over bright ones:

```elixir
# Better for large text
ColorFuncs.wrap(long_text, :teal)

# Too harsh for large text
ColorFuncs.wrap(long_text, :bright_cyan)
```

### 6. Consistent Color Schemes

Define a consistent color scheme for your application:

```elixir
defmodule AppTheme do
  alias BCUtils.ColorFuncs, as: CF
  
  # Primary colors
  def primary(text), do: CF.wrap(text, :blue, [:bold])
  def secondary(text), do: CF.wrap(text, :teal)
  
  # Status colors
  def success(text), do: CF.wrap(text, :emerald, [:bold])
  def danger(text), do: CF.wrap(text, :crimson, [:bold])
  def warning(text), do: CF.wrap(text, :amber, [:bold])
  
  # Text hierarchy
  def heading(text), do: CF.wrap(text, :bright_white, [:bold])
  def subheading(text), do: CF.wrap(text, :bright_white)
  def body(text), do: CF.wrap(text, :white)
  def muted(text), do: CF.wrap(text, :gray8)
end
```

## Color Reference

### Quick Reference Table

| Category | Colors |
|----------|--------|
| **Basic** | black, red, green, yellow, blue, magenta, cyan, white |
| **Bright** | bright_black, bright_red, bright_green, bright_yellow, bright_blue, bright_magenta, bright_cyan, bright_white |
| **Extended** | orange, purple, pink, lime, navy, maroon, olive, teal, silver, gold, coral, salmon, khaki, violet, indigo, crimson, forest, sky, rose, mint |
| **Vibrant** | turquoise, aqua, brown, tan, beige, ivory, lavender, plum, orchid, peach, apricot, lemon, chartreuse, emerald, jade, sapphire, ruby, amber, bronze, copper |
| **Nature** | grass, leaf, ocean, sand, stone, clay, earth, bark, moss, fern |
| **Tech** | neon_green, neon_blue, neon_pink, electric, plasma, laser, matrix, cyber, terminal, hacker |
| **Grayscale** | gray1, gray2, gray3, gray4, gray5, gray6, gray7, gray8, gray9, gray10, gray11, gray12 |

### Effects Reference

| Effect | Description | Support |
|--------|-------------|---------|
| `:bold` | Bold/bright text | Universal |
| `:dim` | Dimmed text | Most terminals |
| `:italic` | Italic text | Limited |
| `:underline` | Underlined text | Most terminals |
| `:blink` | Slow blink | Limited |
| `:rapid_blink` | Rapid blink | Very limited |
| `:reverse` | Reverse video | Most terminals |
| `:hidden` | Hidden text | Most terminals |
| `:strikethrough` | Strikethrough | Modern terminals |

### Function Reference

| Function | Description | Example |
|----------|-------------|---------|
| `fg(color, effects)` | Foreground color with effects | `fg(:red, [:bold])` |
| `bg(color)` | Background color | `bg(:blue)` |
| `tui(fg, bg, effects)` | Complete formatting | `tui(:white, :red, [:bold])` |
| `wrap(text, color, effects)` | Wrap with auto-reset | `wrap("Hello", :green)` |
| `rgb_fg(r, g, b)` | RGB foreground | `rgb_fg(255, 128, 0)` |
| `rgb_bg(r, g, b)` | RGB background | `rgb_bg(0, 0, 255)` |
| `hex_fg(hex)` | Hex foreground | `hex_fg("#FF8000")` |
| `hex_bg(hex)` | Hex background | `hex_bg("#0080FF")` |
| `effect(name)` | Apply effect only | `effect(:bold)` |
| `reset()` | Reset all formatting | `reset()` |
| `available_colors()` | List all colors | `available_colors()` |
| `available_effects()` | List all effects | `available_effects()` |

---

*This guide covers the complete functionality of the `BCUtils.ColorFuncs` module. For more examples and updates, check the module documentation and tests.*
