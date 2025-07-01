defmodule BCUtils.BannerThemes do
  @moduledoc false

  alias BCUtils.ColorFuncs, as: CF

  def green_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 255, 0) <> "#{text}" <> CF.reset()

  def cyan_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(0, 255, 255) <> "#{text}" <> CF.reset()

  def purple_on_true_black(text),
    do: CF.rgb_bg(0, 0, 0) <> CF.rgb_fg(255, 0, 255) <> "#{text}" <> CF.reset()
end
