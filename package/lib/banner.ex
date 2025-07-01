defmodule BCUtils.Banner do
  @moduledoc """
  Provides functionality to display a startup banner.
  """

  import BCUtils.BannerThemes

  @doc """
    Displays a BEAM Campus flavored, emoji-enabled startup banner.
    ## Parameters
  #   * `service_name` - The name of the service
  #   * `service_description` - A short description of the service
  #   * `shoutout` - A shoutout to the BEAM Campus
  # ## Tip
  #   * You can use `BCUtils.ColorFuncs` to colorize name, description and shoutout.
  #   * Add an emoji to the shoutout for extra fun
  """
  @spec display_banner(
          service_name :: String.t(),
          service_description :: String.t(),
          shoutout :: String.t(),
          beam_theme_func :: (String.t() -> String.t()),
          campus_theme_func :: (String.t() -> String.t()),
          description_theme_func :: (String.t() -> String.t())
        ) :: :ok
  def display_banner(
        service_name,
        service_description,
        shoutout,
        beam_theme_func \\ &cyan_on_true_black/1,
        campus_theme_func \\ &green_on_true_black/1,
        description_theme_func \\ &purple_on_true_black/1
      ) do
    beam_section =
      beam_ascii_art()
      |> beam_theme_func.()

    campus_section =
      campus_ascii_art()
      |> campus_theme_func.()

    service_name =
      service_name
      |> description_theme_func.()

    service_description =
      service_description
      |> description_theme_func.()

    shoutout =
      shoutout
      |> description_theme_func.()

    description_section = """

                         #{service_name}
                    #{service_description}
                          #{shoutout}


    """

    show_banner(beam_section, campus_section, description_section)
  end

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

  defp show_banner(beam_section, campus_section, description_section) do
    IO.puts(beam_section)
    IO.puts(campus_section)
    IO.puts(description_section)
  end
end
