defmodule BCUtils.Banner do
  @moduledoc """
  Provides functionality to display a startup banner.
  """

  @spec display_banner(
          service_name :: String.t(),
          service_description :: String.t(),
          shoutout :: String.t()
        ) :: :ok
  def display_banner(service_name, service_description, shoutout) do
    beam_section = beam_ascii_art()
    campus_section = campus_ascii_art()

    description_section = """

                #{service_name}
            #{service_description}
                #{shoutout}


    """

    show_banner(beam_section, campus_section, description_section)
  end

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
