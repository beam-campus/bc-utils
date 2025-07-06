defmodule BCUtils.Banner do
  @moduledoc """
  Provides functionality to display startup banners with ASCII art and custom styling.
  
  This module offers two main banner styles:
  - Text-based banners for simpler displays
  - ASCII art banners for more elaborate startup displays
  
  Both styles support custom color themes and can be easily configured for different services.
  
  ## Features
  
  - ASCII art "BEAM" and "Campus" text
  - Customizable color themes using `BCUtils.BannerThemes`
  - Text-only and full ASCII art banner variants
  - Service information display with configurable styling
  - Built-in default themes optimized for terminal visibility
  
  ## Quick Examples
  
  ### Simple Text Banner
  
  ```elixir
  BCUtils.Banner.display_text_banner(
    "My Service",
    "A great Elixir application",
    "🚀 Powered by BEAM Campus"
  )
  ```
  
  ### Full ASCII Art Banner
  
  ```elixir
  BCUtils.Banner.display_banner(
    "My Service",
    "Event sourcing made simple",
    "⚡ Built with love"
  )
  ```
  
  ### Custom Themes
  
  ```elixir
  import BCUtils.BannerThemes
  
  BCUtils.Banner.display_banner(
    "My Service",
    "Custom styled banner",
    "🎨 Creative themes",
    &amber_on_true_black/1,     # BEAM theme
    &cyan_on_true_black/1,      # Campus theme  
    &purple_on_true_black/1     # Description theme
  )
  ```
  
  ## Configuration Options
  
  Both banner functions accept theme functions as parameters:
  
  - `beam_theme_func` - Colors the "BEAM" text
  - `campus_theme_func` - Colors the "Campus" text
  - `description_theme_func` - Colors service information
  
  All theme functions should follow the signature `(String.t() -> String.t())`.
  """
  
  import BCUtils.BannerThemes
  
  @type theme_function :: (String.t() -> String.t())
  @type banner_config :: %{
    service_name: String.t(),
    service_description: String.t(),
    shoutout: String.t(),
    beam_theme: theme_function(),
    campus_theme: theme_function(),
    description_theme: theme_function()
  }

  @doc """
  Displays a text-based BEAM Campus banner without ASCII art.
  
  This function provides a simpler banner format using just the text "BEAM" and "Campus"
  without the elaborate ASCII art. Perfect for situations where you want a clean,
  minimal banner display.
  
  ## Parameters
  
  - `service_name` - The name of your service or application
  - `service_description` - A brief description of what your service does
  - `shoutout` - A custom message, tagline, or shoutout (emoji supported!)
  - `beam_theme_func` - Function to style the "BEAM" text (defaults to sky blue)
  - `campus_theme_func` - Function to style the "Campus" text (defaults to lime green)
  - `description_theme_func` - Function to style service info (defaults to purple)
  
  ## Examples
  
  ```elixir
  # Basic usage with defaults
  BCUtils.Banner.display_text_banner(
    "MyApp",
    "Event sourcing framework",
    "🚀 Ready to launch!"
  )
  
  # Custom themes
  import BCUtils.BannerThemes
  
  BCUtils.Banner.display_text_banner(
    "DevTools",
    "Development utilities",
    "✨ Built with Elixir",
    &amber_on_true_black/1,
    &cyan_on_true_black/1,
    &green_on_true_black/1
  )
  ```
  
  ## Tips
  
  - Use emojis in the shoutout for visual appeal
  - Choose contrasting theme colors for better readability
  - Keep service descriptions concise for better formatting
  """
  @spec display_text_banner(
          service_name :: String.t(),
          service_description :: String.t(),
          shoutout :: String.t(),
          beam_theme_func :: theme_function(),
          campus_theme_func :: theme_function(),
          description_theme_func :: theme_function()
        ) :: :ok
  def display_text_banner(
        service_name,
        service_description,
        shoutout,
        beam_theme_func \\ &sky_blue_on_true_black/1,
        campus_theme_func \\ &lime_on_true_black/1,
        description_theme_func \\ &purple_on_true_black/1
      )
      when is_binary(service_name) and is_binary(service_description) and is_binary(shoutout) do
    config = %{
      service_name: service_name,
      service_description: service_description,
      shoutout: shoutout,
      beam_theme: beam_theme_func,
      campus_theme: campus_theme_func,
      description_theme: description_theme_func
    }
    
    display_text_banner_with_config(config)
  end

  @doc """
  Displays a full ASCII art BEAM Campus banner with elaborate styling.
  
  This function creates an impressive startup banner featuring ASCII art for both
  "BEAM" and "Campus" text, along with your service information. This is the
  recommended function for production applications that want to make a strong
  visual impression.
  
  ## Parameters
  
  - `service_name` - The name of your service or application
  - `service_description` - A brief description of what your service does
  - `shoutout` - A custom message, tagline, or shoutout (emoji supported!)
  - `beam_theme_func` - Function to style the "BEAM" ASCII art (defaults to sky blue)
  - `campus_theme_func` - Function to style the "Campus" ASCII art (defaults to lime green)
  - `description_theme_func` - Function to style service info (defaults to indigo)
  
  ## Examples
  
  ```elixir
  # Basic usage with defaults
  BCUtils.Banner.display_banner(
    "EventStore",
    "Event sourcing database",
    "⚡ Lightning fast events!"
  )
  
  # Production-ready example
  BCUtils.Banner.display_banner(
    "MyCompany API",
    "RESTful service platform",
    "🎆 Version 2.0 - Now with GraphQL!"
  )
  
  # Custom color themes
  import BCUtils.BannerThemes
  
  BCUtils.Banner.display_banner(
    "DevServer",
    "Local development environment",
    "🔥 Hot reloading enabled",
    &orange_on_true_black/1,    # Orange BEAM
    &violet_on_true_black/1,    # Violet Campus
    &amber_on_true_black/1      # Amber description
  )
  ```
  
  ## Visual Layout
  
  The banner will display in this format:
  ```
  [ASCII ART: BEAM]
  [ASCII ART: CAMPUS]
  
                    Service Name
               Service Description  
                   Shoutout
  ```
  
  ## Tips
  
  - Use this for production applications and demos
  - ASCII art looks best in terminals with good Unicode support
  - Consider terminal width when choosing service names/descriptions
  - Emojis in shoutouts add personality and visual interest
  """
  @spec display_banner(
          service_name :: String.t(),
          service_description :: String.t(),
          shoutout :: String.t(),
          beam_theme_func :: theme_function(),
          campus_theme_func :: theme_function(),
          description_theme_func :: theme_function()
        ) :: :ok
  def display_banner(
        service_name,
        service_description,
        shoutout,
        beam_theme_func \\ &sky_blue_on_true_black/1,
        campus_theme_func \\ &lime_on_true_black/1,
        description_theme_func \\ &indigo_on_true_black/1
      )
      when is_binary(service_name) and is_binary(service_description) and is_binary(shoutout) do
    config = %{
      service_name: service_name,
      service_description: service_description,
      shoutout: shoutout,
      beam_theme: beam_theme_func,
      campus_theme: campus_theme_func,
      description_theme: description_theme_func
    }
    
    display_ascii_banner_with_config(config)
  end

  # Public configuration-based functions
  
  @doc """
  Displays a banner using a configuration map.
  
  This provides a more structured way to configure banners, especially useful
  when banner configuration needs to be stored or passed around.
  
  ## Parameters
  
  - `config` - A `banner_config` map containing all banner settings
  
  ## Example
  
  ```elixir
  config = %{
    service_name: "MyApp",
    service_description: "Awesome application",
    shoutout: "🚀 Ready to go!",
    beam_theme: &BCUtils.BannerThemes.sky_blue_on_true_black/1,
    campus_theme: &BCUtils.BannerThemes.lime_on_true_black/1,
    description_theme: &BCUtils.BannerThemes.purple_on_true_black/1
  }
  
  BCUtils.Banner.display_banner_with_config(config)
  ```
  """
  @spec display_banner_with_config(banner_config()) :: :ok
  def display_banner_with_config(config) when is_map(config) do
    display_ascii_banner_with_config(config)
  end
  
  @doc """
  Creates a banner configuration map with default themes.
  
  This is a convenience function for creating banner configurations
  with sensible defaults that can be customized as needed.
  
  ## Parameters
  
  - `service_name` - The name of your service
  - `service_description` - Brief description of your service
  - `shoutout` - Custom message or tagline
  
  ## Example
  
  ```elixir
  config = BCUtils.Banner.default_config(
    "MyService",
    "Does amazing things",
    "✨ Magic included"
  )
  
  # Customize themes if needed
  config = %{config | beam_theme: &BCUtils.BannerThemes.orange_on_true_black/1}
  
  BCUtils.Banner.display_banner_with_config(config)
  ```
  """
  @spec default_config(String.t(), String.t(), String.t()) :: banner_config()
  def default_config(service_name, service_description, shoutout) 
      when is_binary(service_name) and is_binary(service_description) and is_binary(shoutout) do
    %{
      service_name: service_name,
      service_description: service_description,
      shoutout: shoutout,
      beam_theme: &sky_blue_on_true_black/1,
      campus_theme: &lime_on_true_black/1,
      description_theme: &indigo_on_true_black/1
    }
  end
  
  # Private helper functions for banner configuration
  
  @spec display_text_banner_with_config(banner_config()) :: :ok
  defp display_text_banner_with_config(config) do
    beam_section = beam_text() |> config.beam_theme.()
    campus_section = campus_text() |> config.campus_theme.()
    
    description_section = format_text_description_section(
      config.service_name,
      config.service_description,
      config.shoutout,
      config.description_theme
    )
    
    show_banner(beam_section, campus_section, description_section)
  end
  
  @spec display_ascii_banner_with_config(banner_config()) :: :ok
  defp display_ascii_banner_with_config(config) do
    beam_section = beam_ascii_art() |> config.beam_theme.()
    campus_section = campus_ascii_art() |> config.campus_theme.()
    
    description_section = format_ascii_description_section(
      config.service_name,
      config.service_description,
      config.shoutout,
      config.description_theme
    )
    
    show_banner(beam_section, campus_section, description_section)
  end
  
  # Private functions for ASCII art and text content
  
  @spec beam_ascii_art() :: String.t()
  defp beam_ascii_art do
    """

             ██████╗ ███████╗ █████╗ ███╗   ███╗
             ██╔══██╗██╔════╝██╔══██╗████╗ ████║
             ██████╔╝█████╗  ███████║██╔████╔██║
             ██╔══██╗██╔══╝  ██╔══██║██║╚██╔╝██║
             ██████╔╝███████╗██║  ██║██║ ╚═╝ ██║
             ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
    """
  end

  @spec campus_ascii_art() :: String.t()
  defp campus_ascii_art do
    """

       ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗
      ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝
      ██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗
      ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║
      ╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║
       ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝
    """
  end

  @spec beam_text() :: String.t()
  defp beam_text, do: "BEAM"

  @spec campus_text() :: String.t()
  defp campus_text, do: "Campus"
  
  # Private functions for formatting description sections
  
  @spec format_text_description_section(String.t(), String.t(), String.t(), theme_function()) :: String.t()
  defp format_text_description_section(service_name, service_description, shoutout, theme_func) do
    styled_name = theme_func.(service_name)
    styled_description = theme_func.(service_description)
    styled_shoutout = theme_func.(shoutout)
    
    """
                #{styled_name}
           #{styled_description}
                 #{styled_shoutout}

      """
  end
  
  @spec format_ascii_description_section(String.t(), String.t(), String.t(), theme_function()) :: String.t()
  defp format_ascii_description_section(service_name, service_description, shoutout, theme_func) do
    styled_name = theme_func.(service_name)
    styled_description = theme_func.(service_description)
    styled_shoutout = theme_func.(shoutout)
    
    """

                         #{styled_name}
                    #{styled_description}
                        #{styled_shoutout}


    """
  end
  
  # Final output function
  
  @spec show_banner(String.t(), String.t(), String.t()) :: :ok
  defp show_banner(beam_section, campus_section, description_section) do
    IO.puts(beam_section)
    IO.puts(campus_section)
    IO.puts(description_section)
  end
end
