defmodule BCUtils.BannerThemes do
  @moduledoc false

  alias BCUtils.ColorFuncs, as: CF

  def bright_green(text),
    do: "#{CF.bright_green_on_black()}#{text}#{CF.reset()}"

  def bright_cyan(text),
    do: "#{CF.bright_cyan_on_black()}#{text}#{CF.reset()}"

  def purple(text),
    do: "#{CF.purple_on_black()}#{text}#{CF.reset()}"
end
