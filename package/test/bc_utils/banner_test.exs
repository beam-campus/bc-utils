defmodule BCUtils.BannerTest do
  use ExUnit.Case, async: true
  
  import ExUnit.CaptureIO
  import BCUtils.BannerThemes
  
  alias BCUtils.Banner
  
  describe "display_text_banner/6" do
    test "displays text banner with default themes" do
      output = capture_io(fn ->
        Banner.display_text_banner("TestApp", "Test description", "🚀 Testing!")
      end)
      
      assert output =~ "BEAM"
      assert output =~ "Campus"
      assert output =~ "TestApp"
      assert output =~ "Test description"
      assert output =~ "🚀 Testing!"
    end
    
    test "displays text banner with custom themes" do
      output = capture_io(fn ->
        Banner.display_text_banner(
          "CustomApp",
          "Custom description", 
          "⚡ Custom theme!",
          &green_on_true_black/1,
          &cyan_on_true_black/1,
          &purple_on_true_black/1
        )
      end)
      
      assert output =~ "BEAM"
      assert output =~ "Campus"
      assert output =~ "CustomApp"
      assert output =~ "Custom description"
      assert output =~ "⚡ Custom theme!"
    end
    
    test "validates input parameters" do
      assert_raise FunctionClauseError, fn ->
        Banner.display_text_banner(nil, "description", "shoutout")
      end
      
      assert_raise FunctionClauseError, fn ->
        Banner.display_text_banner("name", nil, "shoutout")
      end
      
      assert_raise FunctionClauseError, fn ->
        Banner.display_text_banner("name", "description", nil)
      end
    end
  end
  
  describe "display_banner/6" do
    test "displays ASCII banner with default themes" do
      output = capture_io(fn ->
        Banner.display_banner("ASCIIApp", "ASCII description", "🎨 ASCII art!")
      end)
      
      assert output =~ "██████╗ ███████╗ █████╗ ███╗   ███╗"  # BEAM ASCII art
      assert output =~ "██████╗ █████╗ ███╗   ███╗██████╗"    # Campus ASCII art
      assert output =~ "ASCIIApp"
      assert output =~ "ASCII description"
      assert output =~ "🎨 ASCII art!"
    end
    
    test "displays ASCII banner with custom themes" do
      output = capture_io(fn ->
        Banner.display_banner(
          "StyledApp",
          "Styled description",
          "✨ Styled banner!",
          &amber_on_true_black/1,
          &violet_on_true_black/1,
          &orange_on_true_black/1
        )
      end)
      
      assert output =~ "██████╗ ███████╗ █████╗ ███╗   ███╗"
      assert output =~ "StyledApp"
      assert output =~ "Styled description"
      assert output =~ "✨ Styled banner!"
    end
    
    test "validates input parameters" do
      assert_raise FunctionClauseError, fn ->
        Banner.display_banner(123, "description", "shoutout")
      end
    end
  end
  
  describe "default_config/3" do
    test "creates configuration with default themes" do
      config = Banner.default_config("TestService", "Test desc", "🚀 Launch!")
      
      assert config.service_name == "TestService"
      assert config.service_description == "Test desc"
      assert config.shoutout == "🚀 Launch!"
      assert is_function(config.beam_theme, 1)
      assert is_function(config.campus_theme, 1)
      assert is_function(config.description_theme, 1)
    end
    
    test "validates input parameters" do
      assert_raise FunctionClauseError, fn ->
        Banner.default_config(nil, "desc", "shoutout")
      end
    end
  end
  
  describe "display_banner_with_config/1" do
    test "displays banner using configuration map" do
      config = %{
        service_name: "ConfigApp",
        service_description: "Config-based app",
        shoutout: "📋 From config!",
        beam_theme: &sky_blue_on_true_black/1,
        campus_theme: &lime_on_true_black/1,
        description_theme: &purple_on_true_black/1
      }
      
      output = capture_io(fn ->
        Banner.display_banner_with_config(config)
      end)
      
      assert output =~ "██████╗ ███████╗ █████╗ ███╗   ███╗"
      assert output =~ "ConfigApp"
      assert output =~ "Config-based app"
      assert output =~ "📋 From config!"
    end
    
    test "requires valid configuration map" do
      assert_raise FunctionClauseError, fn ->
        Banner.display_banner_with_config("not a map")
      end
    end
  end
  
  describe "integration tests" do
    test "text and ASCII banners produce different output" do
      text_output = capture_io(fn ->
        Banner.display_text_banner("App", "Description", "Message")
      end)
      
      ascii_output = capture_io(fn ->
        Banner.display_banner("App", "Description", "Message")
      end)
      
      # ASCII output should be much longer due to ASCII art
      assert String.length(ascii_output) > String.length(text_output)
      
      # Both should contain the same basic content
      assert text_output =~ "App"
      assert ascii_output =~ "App"
      assert text_output =~ "Description"
      assert ascii_output =~ "Description"
      assert text_output =~ "Message"
      assert ascii_output =~ "Message"
    end
    
    test "configuration-based approach produces same output as direct calls" do
      # Direct call
      direct_output = capture_io(fn ->
        Banner.display_banner("DirectApp", "Direct call", "🎯 Direct!")
      end)
      
      # Config-based call
      config = Banner.default_config("DirectApp", "Direct call", "🎯 Direct!")
      config_output = capture_io(fn ->
        Banner.display_banner_with_config(config)
      end)
      
      assert direct_output == config_output
    end
  end
end
