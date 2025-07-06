defmodule BCUtils do
  @moduledoc """
  BCUtils (BEAM Campus Utilities) - A comprehensive collection of utilities for Elixir projects.
  
  This library provides a set of commonly needed utilities for BEAM applications:
  
  ## Modules
  
  ### Display & Formatting
  - `BCUtils.Banner` - ASCII art banners and startup displays
  - `BCUtils.BannerThemes` - Color themes for banners
  - `BCUtils.ColorFuncs` - ANSI color utilities and terminal text formatting
  
  ### Data Manipulation
  - `BCUtils.BitFlags` - Bitwise flag operations for state management
  
  ### System & Infrastructure
  - `BCUtils.PubSubManager` - Phoenix.PubSub management utilities
  - `BCUtils.LoggerFilters` - Logger filters for reducing noise from verbose libraries
  - `BCUtils.Errors` - Standardized error handling and custom exception types
  - `BCUtils.Telemetry` - Telemetry integration for monitoring and performance analysis
  
  ## Quick Start
  
  Add to your `mix.exs`:
  
  ```elixir
  def deps do
    [
      {:bc_utils, "~> 0.10.0"}
    ]
  end
  ```
  
  ## Common Usage Patterns
  
  ### Display a startup banner:
  
  ```elixir
  BCUtils.Banner.display_banner(
    "My Service",
    "A great Elixir application", 
    "🚀 Powered by BEAM Campus"
  )
  ```
  
  ### Manage bit flags:
  
  ```elixir
  # Define your flags
  flags = %{
    1 => "Ready",
    2 => "Processing", 
    4 => "Complete"
  }
  
  # Set flags
  state = BCUtils.BitFlags.set(0, 1)  # Set "Ready"
  state = BCUtils.BitFlags.set(state, 4)  # Add "Complete"
  
  # Check state
  BCUtils.BitFlags.to_string(state, flags)  # "Ready, Complete"
  ```
  
  ### Manage PubSub gracefully:
  
  ```elixir
  # In your supervision tree
  children = [
    BCUtils.PubSubManager.maybe_child_spec(:my_pubsub),
    # other children...
  ]
  |> Enum.filter(& &1)  # Remove nil entries
  ```
  
  ### Color terminal output:
  
  ```elixir
  import BCUtils.ColorFuncs
  
  IO.puts(wrap("Error message", :red, [:bold]))
  IO.puts("#{fg(:green)}Success!#{reset()}")
  ```
  
  ## Documentation
  
  For detailed documentation of each module, see the individual module docs.
  """
  
  @doc """
  Returns the current version of BCUtils.
  """
  @spec version() :: String.t()
  def version do
    Application.spec(:bc_utils, :vsn) |> to_string()
  end
  
  @doc """
  Lists all available modules in BCUtils.
  """
  @spec modules() :: [module()]
  def modules do
    [
      BCUtils.Banner,
      BCUtils.BannerThemes,
      BCUtils.BitFlags,
      BCUtils.ColorFuncs,
      BCUtils.Errors,
      BCUtils.LoggerFilters,
      BCUtils.PubSubManager,
      BCUtils.Telemetry
    ]
  end
end
