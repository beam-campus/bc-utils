defmodule BCUtils.BannerThemesTest do
  use ExUnit.Case, async: true
  
  alias BCUtils.BannerThemes
  alias BCUtils.ColorFuncs
  
  describe "theme functions" do
    test "all theme functions return styled text with reset" do
      themes = [
        :green_on_true_black,
        :cyan_on_true_black,
        :purple_on_true_black,
        :grass_on_true_black,
        :sky_blue_on_true_black,
        :lime_on_true_black,
        :indigo_on_true_black,
        :lavender_on_true_black,
        :violet_on_true_black,
        :amber_on_true_black,
        :orange_on_true_black,
        :maroon_on_true_black
      ]
      
      Enum.each(themes, fn theme ->
        result = apply(BannerThemes, theme, ["test"])
        
        # Should contain the original text
        assert result =~ "test"
        
        # Should contain ANSI escape sequences for styling
        assert result =~ "\\e["
        
        # Should end with reset sequence
        assert result =~ ColorFuncs.reset()
        
        # Should contain RGB background (true black: 0,0,0)
        assert result =~ "48;2;0;0;0"
        
        # Should contain RGB foreground
        assert result =~ "38;2;"
      end)
    end
    
    test "primary color themes" do
      # Green theme
      green_result = BannerThemes.green_on_true_black("GREEN")
      assert green_result =~ "38;2;0;255;0"  # Bright green RGB
      assert green_result =~ "GREEN"
      
      # Cyan theme  
      cyan_result = BannerThemes.cyan_on_true_black("CYAN")
      assert cyan_result =~ "38;2;0;255;255"  # Bright cyan RGB
      assert cyan_result =~ "CYAN"
      
      # Purple theme
      purple_result = BannerThemes.purple_on_true_black("PURPLE")
      assert purple_result =~ "38;2;255;0;255"  # Bright purple RGB
      assert purple_result =~ "PURPLE"
    end
    
    test "nature-inspired color themes" do
      # Grass theme
      grass_result = BannerThemes.grass_on_true_black("GRASS")
      assert grass_result =~ "38;2;0;128;0"  # Dark green RGB
      assert grass_result =~ "GRASS"
      
      # Sky blue theme
      sky_result = BannerThemes.sky_blue_on_true_black("SKY")
      assert sky_result =~ "38;2;135;206;235"  # Sky blue RGB
      assert sky_result =~ "SKY"
      
      # Lime theme
      lime_result = BannerThemes.lime_on_true_black("LIME")
      assert lime_result =~ "38;2;191;255;0"  # Lime green RGB
      assert lime_result =~ "LIME"
    end
    
    test "sophisticated color themes" do
      # Indigo theme
      indigo_result = BannerThemes.indigo_on_true_black("INDIGO")
      assert indigo_result =~ "38;2;75;0;130"  # Indigo RGB
      assert indigo_result =~ "INDIGO"
      
      # Lavender theme
      lavender_result = BannerThemes.lavender_on_true_black("LAVENDER")
      assert lavender_result =~ "38;2;230;230;250"  # Lavender RGB
      assert lavender_result =~ "LAVENDER"
      
      # Violet theme
      violet_result = BannerThemes.violet_on_true_black("VIOLET")
      assert violet_result =~ "38;2;238;130;238"  # Violet RGB
      assert violet_result =~ "VIOLET"
    end
    
    test "warm color themes" do
      # Amber theme
      amber_result = BannerThemes.amber_on_true_black("AMBER")
      assert amber_result =~ "38;2;255;193;7"  # Amber RGB
      assert amber_result =~ "AMBER"
      
      # Orange theme
      orange_result = BannerThemes.orange_on_true_black("ORANGE")
      assert orange_result =~ "38;2;255;165;0"  # Orange RGB
      assert orange_result =~ "ORANGE"
      
      # Maroon theme
      maroon_result = BannerThemes.maroon_on_true_black("MAROON")
      assert maroon_result =~ "38;2;128;0;0"  # Maroon RGB
      assert maroon_result =~ "MAROON"
    end
  end
  
  describe "available_themes/0" do
    test "returns list of all available theme atoms" do
      themes = BannerThemes.available_themes()
      
      assert is_list(themes)
      assert length(themes) > 0
      
      # Check for some expected themes
      expected_themes = [
        :green_on_true_black,
        :cyan_on_true_black,
        :purple_on_true_black,
        :grass_on_true_black,
        :sky_blue_on_true_black,
        :lime_on_true_black,
        :indigo_on_true_black,
        :lavender_on_true_black,
        :violet_on_true_black,
        :amber_on_true_black,
        :orange_on_true_black,
        :maroon_on_true_black
      ]
      
      Enum.each(expected_themes, fn theme ->
        assert theme in themes
      end)
    end
    
    test "all listed themes are actual functions" do
      themes = BannerThemes.available_themes()
      
      Enum.each(themes, fn theme ->
        assert function_exported?(BannerThemes, theme, 1)
      end)
    end
  end
  
  describe "apply_theme/2" do
    test "successfully applies known themes" do
      {:ok, result} = BannerThemes.apply_theme(:sky_blue_on_true_black, "TEST")
      
      assert result =~ "TEST"
      assert result =~ "38;2;135;206;235"  # Sky blue RGB
      assert result =~ ColorFuncs.reset()
    end
    
    test "returns error for unknown themes" do
      assert {:error, :unknown_theme} = BannerThemes.apply_theme(:non_existent_theme, "TEST")
    end
    
    test "works with all available themes" do
      themes = BannerThemes.available_themes()
      
      Enum.each(themes, fn theme ->
        assert {:ok, result} = BannerThemes.apply_theme(theme, "SAMPLE")
        assert result =~ "SAMPLE"
        assert result =~ ColorFuncs.reset()
      end)
    end
    
    test "validates input parameters" do
      # Should handle binary text
      assert {:ok, _} = BannerThemes.apply_theme(:green_on_true_black, "valid text")
      
      # Should handle empty string
      assert {:ok, result} = BannerThemes.apply_theme(:green_on_true_black, "")
      assert result =~ ColorFuncs.reset()
    end
  end
  
  describe "text handling" do
    test "handles empty strings" do
      result = BannerThemes.green_on_true_black("")
      assert result =~ ColorFuncs.reset()
      # Should still have color codes even with empty text
      assert result =~ "48;2;0;0;0"  # Background
      assert result =~ "38;2;0;255;0"  # Foreground
    end
    
    test "handles unicode characters" do
      unicode_text = "🚀 ⚡ ✨ 🎨"
      result = BannerThemes.cyan_on_true_black(unicode_text)
      
      assert result =~ unicode_text
      assert result =~ ColorFuncs.reset()
    end
    
    test "handles multi-line text" do
      multiline = \"\"\"
      Line 1
      Line 2
      Line 3
      \"\"\"
      
      result = BannerThemes.purple_on_true_black(multiline)
      
      assert result =~ "Line 1"
      assert result =~ "Line 2" 
      assert result =~ "Line 3"
      assert result =~ ColorFuncs.reset()
    end
  end
  
  describe "color consistency" do
    test "all themes use true black background" do
      themes = BannerThemes.available_themes()
      
      Enum.each(themes, fn theme ->
        result = apply(BannerThemes, theme, ["test"])
        # All should use RGB background 0,0,0 (true black)
        assert result =~ "48;2;0;0;0"
      end)
    end
    
    test "themes produce different foreground colors" do
      # Get results from different themes
      green = BannerThemes.green_on_true_black("test")
      cyan = BannerThemes.cyan_on_true_black("test")
      purple = BannerThemes.purple_on_true_black("test")
      
      # They should all be different (different RGB values)
      assert green != cyan
      assert cyan != purple
      assert green != purple
    end
  end
end
