defmodule BCUtils.BannerThemes do
  @moduledoc false

  alias BCUtils.ColorFuncs, as: CF

  def green_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 255, 0) <> "#{text}" <> CF.reset()

  def cyan_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 255, 255) <> "#{text}" <> CF.reset()

  def purple_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(255, 0, 255) <> "#{text}" <> CF.reset()

  def grass_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 128, 0) <> "#{text}" <> CF.reset()

  def sky_blue_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(135, 206, 235) <> "#{text}" <> CF.reset()

  def lime_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(191, 255, 0) <> "#{text}" <> CF.reset()

  def indigo_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(75, 0, 130) <> "#{text}" <> CF.reset()

  def lavender_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(230, 230, 250) <> "#{text}" <> CF.reset()

  def violet_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(238, 130, 238) <> "#{text}" <> CF.reset()

  def amber_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(255, 193, 7) <> "#{text}" <> CF.reset()

  def orange_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(255, 165, 0) <> "#{text}" <> CF.reset()

  def maroon_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(128, 0, 0) <> "#{text}" <> CF.reset()
end
