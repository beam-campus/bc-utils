defmodule BCUtils.LoggerFilters do
  @moduledoc """
  Custom logger filters for reducing noise from commonly verbose libraries.
  
  This module provides pre-configured filters that can be used to reduce
  log noise from libraries like Swarm, LibCluster, and others while still
  allowing important error messages through.
  """

  @doc """
  Filter function to reduce Swarm logging noise.
  
  This filter allows only :error level messages from Swarm modules to pass through,
  filtering out :info, :debug, and :warning messages that create noise.
  
  ## Usage
  
  Add to your logger configuration:
  
      config :logger, :console,
        format: "$time [$level] $message\\n",
        metadata: :all,
        filters: [swarm_filter: {BCUtils.LoggerFilters, :filter_swarm}]
  
  """
  def filter_swarm(%{meta: %{mfa: {module, _function, _arity}}, level: level} = log_event) do
    case {is_swarm_module?(module), level} do
      {true, :error} -> log_event  # Allow Swarm errors through
      {true, _} -> :stop           # Filter out non-error Swarm messages
      {false, _} -> log_event      # Allow all non-Swarm messages
    end
  end

  # Handle log events without MFA metadata
  def filter_swarm(%{level: _level} = log_event), do: log_event

  @doc """
  Filter function to reduce LibCluster logging noise.
  
  Similar to filter_swarm/1 but for LibCluster modules.
  """
  def filter_libcluster(%{meta: %{mfa: {module, _function, _arity}}, level: level} = log_event) do
    case {is_libcluster_module?(module), level} do
      {true, :error} -> log_event  # Allow LibCluster errors through
      {true, _} -> :stop           # Filter out non-error LibCluster messages
      {false, _} -> log_event      # Allow all non-LibCluster messages
    end
  end

  def filter_libcluster(%{level: _level} = log_event), do: log_event

  @doc """
  Combined filter for both Swarm and LibCluster noise.
  
  ## Usage
  
      config :logger, :console,
        filters: [verbose_libs: {BCUtils.LoggerFilters, :filter_verbose_libs}]
  """
  def filter_verbose_libs(%{meta: %{mfa: {module, _function, _arity}}, level: level} = log_event) do
    cond do
      is_swarm_module?(module) and level != :error -> :stop
      is_libcluster_module?(module) and level != :error -> :stop
      true -> log_event
    end
  end

  def filter_verbose_libs(%{level: _level} = log_event), do: log_event

  @doc """
  Filter that only allows error and warning messages from specified modules.
  
  ## Usage
  
      config :logger, :console,
        filters: [
          errors_only: {BCUtils.LoggerFilters, :errors_and_warnings_only}
        ]
  """
  def errors_and_warnings_only(%{meta: %{mfa: {module, _function, _arity}}, level: level} = log_event) do
    case {is_noisy_module?(module), level} do
      {true, level} when level in [:error, :warning] -> log_event
      {true, _} -> :stop
      {false, _} -> log_event
    end
  end

  def errors_and_warnings_only(%{level: _level} = log_event), do: log_event

  ## Private Functions

  # Check if a module is part of Swarm
  defp is_swarm_module?(module) when is_atom(module) do
    module_string = Atom.to_string(module)
    String.starts_with?(module_string, "Elixir.Swarm")
  end

  defp is_swarm_module?(_), do: false

  # Check if a module is part of LibCluster
  defp is_libcluster_module?(module) when is_atom(module) do
    module_string = Atom.to_string(module)
    String.starts_with?(module_string, "Elixir.Cluster") or
    String.starts_with?(module_string, "Elixir.LibCluster")
  end

  defp is_libcluster_module?(_), do: false

  # Check if a module is generally known to be noisy
  defp is_noisy_module?(module) when is_atom(module) do
    is_swarm_module?(module) or 
    is_libcluster_module?(module) or
    is_other_noisy_module?(module)
  end

  defp is_noisy_module?(_), do: false

  # Add other commonly noisy modules here
  defp is_other_noisy_module?(module) when is_atom(module) do
    module_string = Atom.to_string(module)
    
    # Add patterns for other noisy libraries
    String.starts_with?(module_string, "Elixir.Phoenix.PubSub") or
    String.starts_with?(module_string, "Elixir.Ranch") or
    String.starts_with?(module_string, "Elixir.Cowboy")
  end

  defp is_other_noisy_module?(_), do: false
end
