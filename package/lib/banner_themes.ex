defmodule BCUtils.BannerThemes do
  @moduledoc """
  Predefined color themes for banner text styling.
  
  This module provides a collection of color functions that combine
  RGB foreground colors with true black backgrounds for high-contrast
  banner displays.
  
  ## Available Themes
  
  ### Primary Colors
  - `green_on_true_black/1` - Bright green text (#00FF00)
  - `cyan_on_true_black/1` - Bright cyan text (#00FFFF) 
  - `purple_on_true_black/1` - Bright purple/magenta text (#FF00FF)
  
  ### Nature-Inspired Colors
  - `grass_on_true_black/1` - Dark green (#008000)
  - `sky_blue_on_true_black/1` - Sky blue (#87CEEB)
  - `lime_on_true_black/1` - Lime green (#BFFF00)
  
  ### Sophisticated Colors
  - `indigo_on_true_black/1` - Deep indigo (#4B0082)
  - `lavender_on_true_black/1` - Lavender (#E6E6FA)
  - `violet_on_true_black/1` - Violet (#EE82EE)
  
  ### Warm Colors
  - `amber_on_true_black/1` - Amber yellow (#FFC107)
  - `orange_on_true_black/1` - Orange (#FFA500)
  - `maroon_on_true_black/1` - Dark red (#800000)
  
  ## Usage
  
  ```elixir
  import BCUtils.BannerThemes
  
  styled_text = sky_blue_on_true_black("BEAM")
  IO.puts(styled_text)
  ```
  
  These functions are designed to be used with `BCUtils.Banner` for
  creating visually appealing startup banners.
  """
  
  alias BCUtils.ColorFuncs, as: CF
  
  @type theme_function :: (String.t() -> String.t())

  # Primary colors
  
  @doc "Applies bright green text (#00FF00) on true black background."
  @spec green_on_true_black(String.t()) :: String.t()
  def green_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 255, 0) <> text <> CF.reset()

  @doc "Applies bright cyan text (#00FFFF) on true black background."
  @spec cyan_on_true_black(String.t()) :: String.t()
  def cyan_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 255, 255) <> text <> CF.reset()

  @doc "Applies bright purple/magenta text (#FF00FF) on true black background."
  @spec purple_on_true_black(String.t()) :: String.t()
  def purple_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(255, 0, 255) <> text <> CF.reset()

  # Nature-inspired colors

  @doc "Applies dark green text (#008000) on true black background."
  @spec grass_on_true_black(String.t()) :: String.t()
  def grass_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 128, 0) <> text <> CF.reset()

  @doc "Applies sky blue text (#87CEEB) on true black background."
  @spec sky_blue_on_true_black(String.t()) :: String.t()
  def sky_blue_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(135, 206, 235) <> text <> CF.reset()

  @doc "Applies lime green text (#BFFF00) on true black background."
  @spec lime_on_true_black(String.t()) :: String.t()
  def lime_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(191, 255, 0) <> text <> CF.reset()

  # Sophisticated colors

  @doc "Applies deep indigo text (#4B0082) on true black background."
  @spec indigo_on_true_black(String.t()) :: String.t()
  def indigo_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(75, 0, 130) <> text <> CF.reset()

  @doc "Applies lavender text (#E6E6FA) on true black background."
  @spec lavender_on_true_black(String.t()) :: String.t()
  def lavender_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(230, 230, 250) <> text <> CF.reset()

  @doc "Applies violet text (#EE82EE) on true black background."
  @spec violet_on_true_black(String.t()) :: String.t()
  def violet_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(238, 130, 238) <> text <> CF.reset()

  # Warm colors

  @doc "Applies amber yellow text (#FFC107) on true black background."
  @spec amber_on_true_black(String.t()) :: String.t()
  def amber_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(255, 193, 7) <> text <> CF.reset()

  @doc "Applies orange text (#FFA500) on true black background."
  @spec orange_on_true_black(String.t()) :: String.t()
  def orange_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(255, 165, 0) <> text <> CF.reset()

  @doc "Applies dark red/maroon text (#800000) on true black background."
  @spec maroon_on_true_black(String.t()) :: String.t()
  def maroon_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(128, 0, 0) <> text <> CF.reset()

  # Utility functions

  @doc """
  Returns a list of all available theme functions.
  
  ## Example
  
      iex> BCUtils.BannerThemes.available_themes()
      [
        :green_on_true_black,
        :cyan_on_true_black,
        # ... more themes
      ]
  """
  @spec available_themes() :: [atom()]
  def available_themes do
    [
      # Primary colors
      :green_on_true_black,
      :cyan_on_true_black,
      :purple_on_true_black,
      # Nature-inspired colors
      :grass_on_true_black,
      :sky_blue_on_true_black,
      :lime_on_true_black,
      # Sophisticated colors
      :indigo_on_true_black,
      :lavender_on_true_black,
      :violet_on_true_black,
      # Warm colors
      :amber_on_true_black,
      :orange_on_true_black,
      :maroon_on_true_black
    ]
  end

  @doc """
  Applies a theme function by name to the given text.
  
  ## Parameters
  
  - `theme_name` - The atom name of the theme function
  - `text` - The text to style
  
  ## Example
  
      iex> BCUtils.BannerThemes.apply_theme(:sky_blue_on_true_black, "BEAM")
      "\e[48;2;0;0;0m\e[38;2;135;206;235mBEAM\e[0m"
  
  ## Returns
  
  - `{:ok, styled_text}` if theme exists
  - `{:error, :unknown_theme}` if theme doesn't exist
  """
  @spec apply_theme(atom(), String.t()) :: {:ok, String.t()} | {:error, :unknown_theme}
  def apply_theme(theme_name, text) when is_atom(theme_name) and is_binary(text) do
    if theme_name in available_themes() do
      styled_text = apply(__MODULE__, theme_name, [text])
      {:ok, styled_text}
    else
      {:error, :unknown_theme}
    end
  end
end
