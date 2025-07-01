defmodule BCUtils.ColorFuncs do
  @moduledoc """
    This module is used to manipulate colors.
    It offers a set of functions that can be used to 
    change the color of text in the terminal, using ANSI escape codes.
    It covers all color combinations and effects supported by ANSI.
  """

  # Reset
  def reset, do: "\e[0m"

  # Basic colors (0-7), bright colors (8-15), and extended 256-color palette
  @colors [
    # Standard 16 colors
    black: 0,
    red: 1,
    green: 2,
    yellow: 3,
    blue: 4,
    magenta: 5,
    cyan: 6,
    white: 7,
    bright_black: 8,
    bright_red: 9,
    bright_green: 10,
    bright_yellow: 11,
    bright_blue: 12,
    bright_magenta: 13,
    bright_cyan: 14,
    bright_white: 15,

    # Extended colors (216 color cube + grayscale)
    # Popular extended colors for better aesthetics
    orange: 208,
    purple: 129,
    pink: 213,
    lime: 154,
    navy: 17,
    maroon: 52,
    olive: 58,
    teal: 30,
    silver: 248,
    gold: 220,
    coral: 209,
    salmon: 210,
    khaki: 222,
    violet: 99,
    indigo: 54,
    crimson: 124,
    forest: 22,
    sky: 117,
    rose: 225,
    mint: 121,

    # Additional vibrant colors
    turquoise: 80,
    aqua: 87,
    brown: 94,
    tan: 180,
    beige: 230,
    ivory: 255,
    lavender: 183,
    plum: 96,
    orchid: 170,
    peach: 216,
    apricot: 215,
    lemon: 227,
    chartreuse: 118,
    emerald: 46,
    jade: 78,
    sapphire: 63,
    ruby: 160,
    amber: 214,
    bronze: 130,
    copper: 173,

    # Nature-inspired colors
    grass: 34,
    leaf: 70,
    ocean: 24,
    sand: 229,
    stone: 245,
    clay: 137,
    earth: 94,
    bark: 58,
    moss: 65,
    fern: 29,

    # Modern/Tech colors
    neon_green: 118,
    neon_blue: 39,
    neon_pink: 199,
    electric: 51,
    plasma: 165,
    laser: 196,
    matrix: 40,
    cyber: 45,
    terminal: 76,
    hacker: 82,

    # Grayscale variations
    gray1: 232,
    gray2: 234,
    gray3: 236,
    gray4: 238,
    gray5: 240,
    gray6: 242,
    gray7: 244,
    gray8: 246,
    gray9: 248,
    gray10: 250,
    gray11: 252,
    gray12: 254
  ]

  # Text effects
  @effects [
    bold: 1,
    dim: 2,
    italic: 3,
    underline: 4,
    blink: 5,
    rapid_blink: 6,
    reverse: 7,
    hidden: 8,
    strikethrough: 9
  ]

  # Convert lists to maps for easy lookup
  @colors_map Enum.into(@colors, %{})
  @effects_map Enum.into(@effects, %{})

  def tui(fg_color, bg_color, effects \\ []) do
    fg_code = Map.get(@colors_map, fg_color)
    bg_code = Map.get(@colors_map, bg_color)

    effect_codes =
      effects
      |> Enum.map_join(";", &Map.get(@effects_map, &1))

    "\e[38;5;#{fg_code};48;5;#{bg_code};#{effect_codes}m"
  end

  @doc """
  Creates a foreground color with optional effects.

  ## Examples
      iex> ColorFuncs.fg(:red, [:bold])
      "\e[38;5;1;1m"
  """
  def fg(color, effects \\ []) do
    color_code = Map.get(@colors_map, color)
    effect_codes = effects |> Enum.map_join(";", &Map.get(@effects_map, &1))

    case effect_codes do
      "" -> "\e[38;5;#{color_code}m"
      _ -> "\e[38;5;#{color_code};#{effect_codes}m"
    end
  end

  @doc """
  Creates a background color.

  ## Examples
      iex> ColorFuncs.bg(:blue)
      "\e[48;5;4m"
  """
  def bg(color) do
    color_code = Map.get(@colors_map, color)
    "\e[48;5;#{color_code}m"
  end

  @doc """
  Creates RGB foreground color (24-bit true color).

  ## Examples
      iex> ColorFuncs.rgb_fg(255, 128, 0)
      "\e[38;2;255;128;0m"
  """
  def rgb_fg(r, g, b) when r in 0..255 and g in 0..255 and b in 0..255 do
    "\e[38;2;#{r};#{g};#{b}m"
  end

  @doc """
  Creates RGB background color (24-bit true color).

  ## Examples
      iex> ColorFuncs.rgb_bg(0, 128, 255)
      "\e[48;2;0;128;255m"
  """
  def rgb_bg(r, g, b) when r in 0..255 and g in 0..255 and b in 0..255 do
    "\e[48;2;#{r};#{g};#{b}m"
  end

  @doc """
  Creates a hex color for foreground.

  ## Examples
      iex> ColorFuncs.hex_fg("#FF8000")
      "\e[38;2;255;128;0m"
  """
  def hex_fg(hex_string) do
    {r, g, b} = hex_to_rgb(hex_string)
    rgb_fg(r, g, b)
  end

  @doc """
  Creates a hex color for background.

  ## Examples
      iex> ColorFuncs.hex_bg("#0080FF")
      "\e[48;2;0;128;255m"
  """
  def hex_bg(hex_string) do
    {r, g, b} = hex_to_rgb(hex_string)
    rgb_bg(r, g, b)
  end

  @doc """
  Applies an effect without changing colors.

  ## Examples
      iex> ColorFuncs.effect(:bold)
      "\e[1m"
  """
  def effect(effect_name) do
    effect_code = Map.get(@effects_map, effect_name)
    "\e[#{effect_code}m"
  end

  @doc """
  Wraps text with color/effect and automatically resets.

  ## Examples
      iex> ColorFuncs.wrap("Hello", :red, [:bold])
      "\e[38;5;1;1mHello\e[0m"
  """
  def wrap(text, color, effects \\ []) do
    color_code = fg(color, effects)
    "#{color_code}#{text}#{reset()}"
  end

  @doc """
  Lists all available colors.
  """
  def available_colors, do: Map.keys(@colors_map)

  @doc """
  Lists all available effects.
  """
  def available_effects, do: Map.keys(@effects_map)

  # Private helper function to convert hex to RGB
  defp hex_to_rgb("#" <> hex), do: hex_to_rgb(hex)

  defp hex_to_rgb(hex) when byte_size(hex) == 6 do
    <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>> = hex
    {String.to_integer(r, 16), String.to_integer(g, 16), String.to_integer(b, 16)}
  end

  # Generate all color combinations
  contents =
    for {fg_name, fg_code} <- @colors, {bg_name, bg_code} <- @colors do
      f_name = String.to_atom("#{fg_name}_on_#{bg_name}")
      f_body = "\e[38;5;#{fg_code};48;5;#{bg_code}m"

      IO.puts("Declaring function #{f_name}")

      quote bind_quoted: [f_name: f_name, f_body: f_body] do
        def unquote(f_name)(), do: unquote(f_body)
      end
    end

  Module.eval_quoted(__MODULE__, contents, [])
  # Code.eval_quoted(contents, [])
end
