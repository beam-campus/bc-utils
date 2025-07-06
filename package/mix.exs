defmodule BCUtils.MixProject do
  @moduledoc false
  use Mix.Project

  @app_name :bc_utils
  @elixir_version "~> 1.17"
  @version "0.10.0"
  @source_url "https://github.com/beam-campus/bc-utils"
  #  @homepage_url "https://github.com/beam-campus/ex-esdb"
  @docs_url "https://hexdocs.pm/bc_utils"
  # @package_url "https://hex.pm/packages/ex_esdb"
  # @issues_url "https://github.com/beam-campus/ex-esdb/issues"
  @description "BCUtils (Beam Campus Utils) is a collection of utilities and novelty helpers  for Elixir projects."

  def project do
    [
      app: @app_name,
      version: @version,
      deps: deps(),
      elixir: @elixir_version,
      elixirc_paths: elixirc_paths(Mix.env()),
      consolidate_protocols: Mix.env() != :test,
      description: @description,
      docs: docs(),
      package: package(),
      releases: releases(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: coverage_tool()],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "test.watch": :test,
        credo: :dev,
        dialyzer: :dev
      ]
    ]
  end

  defp releases,
    do: [
      bc_utils: [
        include_erts: true,
        include_executables_for: [:unix],
        steps: [:assemble, :tar],
        applications: [
          runtime_tools: :permanent,
          logger: :permanent
        ]
      ]
    ]

  # Run "mix help compile.app" to learn about applications.
  def application,
    do: [
      extra_applications:
        [
          :logger
        ] ++ extra_applications(Mix.env())
    ]

  defp extra_applications(:dev),
    do: [
      :wx,
      :observer
    ]

  defp extra_applications(_), do: []

  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/support"
    ]

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Development tools
      {:dialyze, "~> 0.2.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.37", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      
      # Testing tools
      {:mix_test_watch, "~> 1.1", only: [:dev, :test], runtime: false},
      {:eunit_formatters, "~> 0.5", only: [:test], runtime: false},
      {:excoveralls, "~> 0.18", only: [:test], runtime: false},
      
      # Runtime dependencies - optional
      {:jason, "~> 1.4", optional: true},
      {:phoenix_pubsub, "~> 2.1", optional: true},
      
      # Runtime dependencies - required
      {:uuidv7, "~> 1.0"},
      {:elixir_uuid, "~> 1.2"},
      {:telemetry, "~> 1.0"}
    ]
  end

  defp coverage_tool do
    case System.get_env("CI") do
      "true" -> ExCoveralls
      _ -> {:cover, [output: "_build/cover"]}
    end
  end

  defp docs do
    [
      main: "readme",
      canonical: @docs_url,
      source_ref: "v#{@version}",
      extra_section: "guides",
      extras: [
        "guides/getting_started.md": [
          filename: "getting-started",
          title: "Getting Started"
        ],
        "guides/working_with_bitflags.md": [
          filename: "working-with-bitflags",
          title: "Working with Bitflags"
        ],
        "guides/working_with_colors.md": [
          filename: "working-with-colors",
          title: "Working with Colors"
        ],
        "guides/resolving_phoenix_pubsub_conflicts.md": [
          filename: "resolving-phoenix-pubsub-conflicts",
          title: "Resolving Phoenix.PubSub Conflicts"
        ],
        "guides/filtering_swarm_logs.md": [
          filename: "filtering-swarm-logs",
          title: "Filtering Swarm Logs"
        ],
        "guides/working_with_banners.md": [
          filename: "working-with-banners",
          title: "Working with Banners"
        ],
        "README.md": [
          filename: "readme",
          title: "Read Me"
        ],
        "CHANGELOG.md": [
          filename: "changelog",
          title: "Changelog"
        ]
      ]
    ]
  end

  defp package do
    [
      name: @app_name,
      description: @description,
      version: @version,
      maintainers: ["rgfaber"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      source_url: @source_url
    ]
  end
end
