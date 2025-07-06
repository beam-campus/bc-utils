# Working with Banners

The `BCUtils.Banner` and `BCUtils.BannerThemes` modules provide a comprehensive solution for creating visually appealing startup banners in your Elixir applications.

## Features

- **Two Banner Styles**: Choose between simple text banners or elaborate ASCII art banners
- **Rich Color Themes**: 12+ predefined color themes organized by category
- **Flexible Configuration**: Use function parameters or configuration maps
- **Unicode Support**: Full support for emojis and Unicode characters
- **Type Safety**: Comprehensive type specifications and input validation

## Quick Start

### Basic ASCII Art Banner

```elixir
BCUtils.Banner.display_banner(
  "MyApp",
  "Event sourcing framework",
  "🚀 Ready for production!"
)
```

### Simple Text Banner

```elixir
BCUtils.Banner.display_text_banner(
  "DevTools",
  "Development utilities",
  "⚡ Hot reloading enabled"
)
```

## Banner Styles

### ASCII Art Banner (`display_banner/6`)

Creates an impressive banner with ASCII art for "BEAM" and "Campus":

```
             ██████╗ ███████╗ █████╗ ███╗   ███╗
             ██╔══██╗██╔════╝██╔══██╗████╗ ████║
             ██████╔╝█████╗  ███████║██╔████╔██║
             ██╔══██╗██╔══╝  ██╔══██║██║╚██╔╝██║
             ██████╔╝███████╗██║  ██║██║ ╚═╝ ██║
             ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝

       ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗
      ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝
      ██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗
      ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║
      ╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║
       ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝

                         MyApp
                    Event sourcing framework
                        🚀 Ready for production!
```

**Best for**: Production applications, demos, important announcements

### Text Banner (`display_text_banner/6`)

Creates a cleaner, more minimal banner:

```
BEAM
Campus

                MyApp
           Event sourcing framework
                 🚀 Ready for production!
```

**Best for**: Development environments, simpler displays, space-constrained terminals

## Color Themes

### Primary Colors
- `green_on_true_black` - Bright green (#00FF00)
- `cyan_on_true_black` - Bright cyan (#00FFFF)
- `purple_on_true_black` - Bright purple/magenta (#FF00FF)

### Nature-Inspired Colors
- `grass_on_true_black` - Dark green (#008000)
- `sky_blue_on_true_black` - Sky blue (#87CEEB)
- `lime_on_true_black` - Lime green (#BFFF00)

### Sophisticated Colors
- `indigo_on_true_black` - Deep indigo (#4B0082)
- `lavender_on_true_black` - Lavender (#E6E6FA)
- `violet_on_true_black` - Violet (#EE82EE)

### Warm Colors
- `amber_on_true_black` - Amber yellow (#FFC107)
- `orange_on_true_black` - Orange (#FFA500)
- `maroon_on_true_black` - Dark red (#800000)

## Advanced Usage

### Custom Theme Functions

```elixir
import BCUtils.BannerThemes

BCUtils.Banner.display_banner(
  "CustomApp",
  "Beautifully styled",
  "🎨 Custom colors!",
  &amber_on_true_black/1,     # BEAM in amber
  &violet_on_true_black/1,    # Campus in violet
  &orange_on_true_black/1     # Description in orange
)
```

### Configuration-Based Approach

```elixir
# Create default configuration
config = BCUtils.Banner.default_config(
  "MyService",
  "Does amazing things",
  "✨ Magic included"
)

# Customize as needed
config = %{config | 
  beam_theme: &BCUtils.BannerThemes.orange_on_true_black/1,
  campus_theme: &BCUtils.BannerThemes.cyan_on_true_black/1
}

# Display the banner
BCUtils.Banner.display_banner_with_config(config)
```

### Dynamic Theme Selection

```elixir
# Get all available themes
themes = BCUtils.BannerThemes.available_themes()

# Apply a theme dynamically
{:ok, styled_text} = BCUtils.BannerThemes.apply_theme(:sky_blue_on_true_black, "BEAM")
IO.puts(styled_text)
```

## Best Practices

### Theme Selection
- **High Contrast**: All themes use true black backgrounds for maximum contrast
- **Color Categories**: Choose themes from the same category for cohesive styling
- **Environment Specific**: Use warmer colors for production, cooler for development

### Text Content
- **Service Names**: Keep concise for better formatting
- **Descriptions**: Brief, descriptive phrases work best
- **Shoutouts**: Add personality with emojis and creative messages

### Performance
- **Startup Only**: Display banners only during application startup
- **Terminal Detection**: Consider detecting terminal capabilities before showing elaborate banners
- **Caching**: For repeated use, consider caching styled strings

## Integration Examples

### Phoenix Application

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    # Display banner on startup
    BCUtils.Banner.display_banner(
      "MyApp API",
      "RESTful microservice platform", 
      "🌐 Version #{Application.spec(:my_app, :vsn)} ready!"
    )

    children = [
      # ... your children
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end
```

### GenServer with Configuration

```elixir
defmodule MyApp.Worker do
  use GenServer

  def start_link(opts) do
    # Show banner with custom configuration
    banner_config = %{
      service_name: "Background Worker",
      service_description: "Processing queue events",
      shoutout: "⚙️ Worker #{inspect(self())} online",
      beam_theme: &BCUtils.BannerThemes.grass_on_true_black/1,
      campus_theme: &BCUtils.BannerThemes.lime_on_true_black/1,
      description_theme: &BCUtils.BannerThemes.green_on_true_black/1
    }
    
    BCUtils.Banner.display_banner_with_config(banner_config)
    
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
end
```

### Mix Task

```elixir
defmodule Mix.Tasks.MyApp.Deploy do
  use Mix.Task

  def run(_args) do
    BCUtils.Banner.display_text_banner(
      "Deployment Task",
      "Deploying to production",
      "🚀 T-minus 3... 2... 1..."
    )
    
    # ... deployment logic
  end
end
```

## Testing

The banner modules include comprehensive test coverage. You can test banner output using `ExUnit.CaptureIO`:

```elixir
import ExUnit.CaptureIO

test "banner displays correctly" do
  output = capture_io(fn ->
    BCUtils.Banner.display_banner("Test", "Testing", "✅ Success")
  end)
  
  assert output =~ "Test"
  assert output =~ "Testing" 
  assert output =~ "✅ Success"
end
```

## Terminal Compatibility

- **Unicode Support**: Best experience with terminals supporting Unicode
- **Color Support**: Requires terminals with 24-bit RGB color support
- **Fallback**: Consider implementing fallbacks for limited terminals
- **Width Considerations**: ASCII art is optimized for standard terminal widths (80+ columns)

## Contributing

When adding new color themes:

1. Follow the `color_name_on_true_black` naming convention
2. Use RGB values that provide good contrast against black
3. Add comprehensive documentation with hex color codes
4. Include the new theme in `available_themes/0`
5. Add thorough test coverage

## Troubleshooting

### Colors Not Displaying
- Verify terminal supports 24-bit RGB colors
- Check if ANSI escape sequences are enabled
- Test with a simpler terminal or different application

### ASCII Art Corruption
- Ensure terminal width is sufficient (80+ columns recommended)
- Verify Unicode support in terminal
- Check font rendering of box-drawing characters

### Performance Issues
- Consider using text banners instead of ASCII art
- Cache styled strings for repeated use
- Display banners only during startup, not on every request
